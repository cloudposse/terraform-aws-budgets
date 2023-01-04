# TODO: use `optional` when it's GA
variable "budgets" {
  type        = any
  description = <<-EOF
  A list of Budgets to be managed by this module, see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget#argument-reference
  for a list of possible attributes. For a more specific example, see `examples/complete/fixtures.us-east-2.tfvars` in this repository.
  EOF
  default     = []
}

variable "notifications_enabled" {
  type        = bool
  description = "Whether or not to setup Slack notifications. Set to `true` to create an SNS topic and Lambda function to send alerts to Slack."
  default     = false
}

variable "encryption_enabled" {
  type        = bool
  description = "Whether or not to use encryption. If set to `true` and no custom value for KMS key (kms_master_key_id) is provided, a KMS key is created."
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = "The ID of a KMS CMK to be used for encryption (see https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-sns-policy.html#protect-sns-sse for appropriate key policies)."
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resources"
  default     = 7
}

variable "kms_enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled"
  default     = true
}

variable "slack_webhook_url" {
  type        = string
  description = "The URL of Slack webhook. Only used when `notifications_enabled` is `true`"
  default     = ""
}

variable "slack_channel" {
  type        = string
  description = "The name of the channel in Slack for notifications. Only used when `notifications_enabled` is `true`"
  default     = ""
}

variable "slack_username" {
  type        = string
  description = "The username that will appear on Slack messages. Only used when `notifications_enabled` is `true`"
  default     = ""
}

variable "slack_emoji" {
  type        = string
  description = "A custom emoji that will appear on Slack messages"
  default     = ":amazon-aws:"
}
