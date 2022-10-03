region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "budgets"

budgets = [
  {
    name            = "budget-ec2-monthly"
    budget_type     = "COST"
    limit_amount    = "1200"
    limit_unit      = "USD"
    time_period_end = "2087-06-15_00:00"
    time_unit       = "MONTHLY"

    cost_filter = {
      Service = ["Amazon Elastic Compute Cloud - Compute"]
    }

    cost_types = {
      include_credit             = true
      include_discount           = true
      include_other_subscription = false
      include_recurring          = true
      include_refund             = false
      include_subscription       = true
      include_support            = false
      include_tax                = true
      include_upfront            = false
      use_blended                = false
    }

    notification = {
      comparison_operator = "GREATER_THAN"
      threshold           = "100"
      threshold_type      = "PERCENTAGE"
      notification_type   = "FORECASTED"
    }
  },
  {
    name         = "100-total-monthly"
    budget_type  = "COST"
    limit_amount = "100"
    limit_unit   = "USD"
    time_unit    = "MONTHLY"
  },
  {
    name         = "s3-3GB-limit-monthly"
    budget_type  = "USAGE"
    limit_amount = "3"
    limit_unit   = "GB"
    time_unit    = "MONTHLY"
  }
]

encryption_enabled = true

notifications_enabled = true

slack_webhook_url = "url"

slack_channel = "channel"

slack_username = "user"
