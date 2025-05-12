locals {
  enabled               = module.this.enabled
  encryption_enabled    = var.encryption_enabled
  notifications_enabled = local.enabled && var.notifications_enabled
  create_kms_key        = local.enabled && local.notifications_enabled && local.encryption_enabled && var.kms_master_key_id == null

  budgets = { for i, budget in var.budgets : i => budget if module.this.enabled }
}

# budgets does not work well with default SNS KMS key (alias/aws/sns)
# optionally create a KMS key with the proper policy when `encryption_enabled` is `true` and an external KMS
# key is not passed via `var.kms_master_key_id`
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  count = local.create_kms_key ? 1 : 0

  statement {
    sid    = "Allow the account identity to manage the KMS key"
    effect = "Allow"

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:aws:iam::%s:root", join("", data.aws_caller_identity.current.*.account_id))
      ]
    }
  }

  statement {
    sid    = "Allow Budgets to use key for notifications"
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["*"]

    principals {
      type = "Service"

      identifiers = [
        "budgets.amazonaws.com"
      ]
    }
  }
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  enabled    = local.create_kms_key
  attributes = ["budgets"]

  description             = "Used to encrypt budget notification data"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation

  policy = join("", data.aws_iam_policy_document.kms_key_policy[*].json)

  context = module.this.context
}

# see https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-sns-policy.html
module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.21.0"

  enabled    = local.notifications_enabled
  attributes = ["budgets"]

  allowed_aws_services_for_sns_published = ["budgets.amazonaws.com"]

  encryption_enabled = var.encryption_enabled
  kms_master_key_id  = local.create_kms_key ? module.kms_key.key_id : var.kms_master_key_id

  context = module.this.context
}

module "slack_notify_lambda" {
  source  = "cloudposse/sns-lambda-notify-slack/aws"
  version = "0.9.0"

  enabled    = local.notifications_enabled
  attributes = ["budgets"]

  # use `module.sns_topic` instead of creating a new topic
  create_sns_topic = false

  # the underlying module uses this in a template string, and cannot be null, so instead when `null` pass an empty string
  # see https://github.com/terraform-aws-modules/terraform-aws-notify-slack/blob/master/main.tf#L8
  sns_topic_name = module.sns_topic.sns_topic_name != null ? module.sns_topic.sns_topic_name : ""

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username
  slack_emoji       = var.slack_emoji

  # underlying module doesn't like when `kms_key_arn` is `null`
  kms_key_arn = local.create_kms_key ? module.kms_key.key_arn : (var.kms_master_key_id == null ? "" : var.kms_master_key_id)

  # if the Lambda should be deployed in a VPC use these
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  context = module.this.context
}

resource "aws_budgets_budget" "default" {
  for_each = local.budgets

  name              = format("%s-%s", module.this.id, each.value.name)
  account_id        = lookup(each.value, "account_id", null)
  budget_type       = each.value.budget_type
  limit_amount      = each.value.limit_amount
  limit_unit        = lookup(each.value, "limit_unit", "USD")
  time_period_start = lookup(each.value, "time_period_start", null)
  time_period_end   = lookup(each.value, "time_period_end", null)
  time_unit         = each.value.time_unit

  dynamic "auto_adjust_data" {
    for_each = lookup(each.value, "auto_adjust_data", null) != null ? try(tolist(each.value.auto_adjust_data), [
      each.value.auto_adjust_data
    ]) : []

    content {
      auto_adjust_type = auto_adjust_data.value.auto_adjust_type
    }
  }

  dynamic "cost_types" {
    for_each = lookup(each.value, "cost_types", null) != null ? [each.value.cost_types] : []

    content {
      include_credit             = lookup(cost_types.value, "include_credit", null)
      include_discount           = lookup(cost_types.value, "include_discount", null)
      include_other_subscription = lookup(cost_types.value, "include_other_subscription", null)
      include_recurring          = lookup(cost_types.value, "include_recurring", null)
      include_refund             = lookup(cost_types.value, "include_refund", null)
      include_subscription       = lookup(cost_types.value, "include_subscription", null)
      include_support            = lookup(cost_types.value, "include_support", null)
      include_tax                = lookup(cost_types.value, "include_tax", null)
      include_upfront            = lookup(cost_types.value, "include_upfront", null)
      use_blended                = lookup(cost_types.value, "use_blended", null)
      use_amortized              = lookup(cost_types.value, "use_amortized", null)
    }
  }

  dynamic "cost_filter" {
    for_each = lookup(each.value, "cost_filter", null) != null ? each.value.cost_filter : {}

    content {
      name   = cost_filter.key
      values = cost_filter.value
    }
  }

  dynamic "notification" {
    for_each = lookup(each.value, "notification", null) != null ? try(tolist(each.value.notification), [
      each.value.notification
    ]) : []

    content {
      comparison_operator = notification.value.comparison_operator
      threshold           = notification.value.threshold
      threshold_type      = notification.value.threshold_type
      notification_type   = notification.value.notification_type
      # use SNS topic when `sns_notification_enabled` is true, otherwise either of these values must be present in budgets.notification object
      subscriber_sns_topic_arns = local.notifications_enabled ? [
        module.sns_topic.sns_topic_arn
      ] : lookup(notification.value, "subscriber_sns_topic_arns", null)
      subscriber_email_addresses = lookup(notification.value, "subscriber_email_addresses", null)
    }
  }

  dynamic "planned_limit" {
    for_each = lookup(each.value, "planned_limits", null) != null ? try(tolist(each.value.planned_limits), [
      each.value.planned_limits
    ]) : []
    content {
      start_time = planned_limit.value.start_time
      amount     = planned_limit.value.amount
      unit       = planned_limit.value.unit
    }
  }
}
