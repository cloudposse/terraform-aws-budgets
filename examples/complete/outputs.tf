output "budgets" {
  description = "List of Budgets that are being managed by this module"
  value       = module.budgets.budgets
}

output "lambda_iam_role_arn" {
  description = "The ARN of the IAM role used by Lambda function"
  value       = module.budgets.lambda_iam_role_arn
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.budgets.lambda_function_arn
}

output "lambda_function_invoke_arn" {
  description = "The ARN to be used for invoking lambda function from API Gateway"
  value       = module.budgets.lambda_function_invoke_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.budgets.lambda_function_name
}

output "lambda_cloudwatch_log_group_arn" {
  description = "The ARN of the Log Group used by the Slack Notify Lambda"
  value       = module.budgets.lambda_cloudwatch_log_group_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS CMK that was created specifically for budget notifications"
  value       = module.budgets.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS CMK that is used for SNS alerts"
  value       = module.budgets.kms_key_id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic created for alerts"
  value       = module.budgets.sns_topic_arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic created for notifications"
  value       = module.budgets.sns_topic_name
}
