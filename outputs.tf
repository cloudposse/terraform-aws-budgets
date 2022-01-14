output "budgets" {
  description = "List of Budgets that are being managed by this module"
  value       = local.enabled ? aws_budgets_budget.default[*] : null
}

output "lambda_iam_role_arn" {
  description = "The ARN of the IAM role used by Lambda function"
  value       = module.slack_notify_lambda.lambda_iam_role_arn
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.slack_notify_lambda.notify_slack_lambda_function_arn
}

output "lambda_function_invoke_arn" {
  description = "The ARN to be used for invoking lambda function from API Gateway"
  value       = module.slack_notify_lambda.notify_slack_lambda_function_invoke_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.slack_notify_lambda.notify_slack_lambda_function_name
}

output "lambda_cloudwatch_log_group_arn" {
  description = "The ARN of the Log Group used by the Slack Notify Lambda"
  value       = module.slack_notify_lambda.lambda_cloudwatch_log_group_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS CMK that was created specifically for budget notifications"
  value       = local.create_kms_key ? module.kms_key.key_arn : null
}

output "kms_key_id" {
  description = "ID of the KMS CMK that is used for SNS notifications"
  value       = local.encryption_enabled ? (local.create_kms_key ? module.kms_key.key_id : var.kms_master_key_id) : null
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic created for notifications"
  value       = local.notifications_enabled ? module.sns_topic.sns_topic_arn : null
}

output "sns_topic_name" {
  description = "The name of the SNS topic created for notifications"
  value       = local.notifications_enabled ? module.sns_topic.sns_topic_name : null
}
