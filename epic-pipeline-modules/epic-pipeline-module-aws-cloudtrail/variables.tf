# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the trail."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "s3_bucket_name" {
  description = "S3 bucket name where trail logs are written. The bucket must have a trail-friendly bucket policy already in place."
  type        = string
}

# Optional inputs
variable "custom_trail_name" {
  description = "Full trail name override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "s3_key_prefix" {
  description = "Optional key prefix for trail logs in the destination bucket."
  type        = string
  default     = null
  nullable    = true
}

variable "include_global_service_events" {
  description = "Whether the trail captures global service events (IAM, CloudFront, etc.). SAF requires this for at least one trail per account."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Whether the trail captures events from all regions."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is an organization trail. Almost always false for application-level trails."
  type        = bool
  default     = false
}

variable "enable_log_file_validation" {
  description = "Whether log file integrity validation is enabled."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether the trail starts logging on creation."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS Key ARN used to encrypt log files. Recommended for application-specific trails handling Confidential data."
  type        = string
  default     = null
  nullable    = true
}

variable "sns_topic_name" {
  description = "Optional SNS topic name to receive log file delivery notifications."
  type        = string
  default     = null
  nullable    = true
}

variable "cloudwatch_logs_group_arn" {
  description = "CloudWatch Logs group ARN for trail log delivery. Both this and cloudwatch_logs_role_arn must be provided to enable CloudWatch integration."
  type        = string
  default     = null
  nullable    = true
}

variable "cloudwatch_logs_role_arn" {
  description = "IAM role ARN CloudTrail assumes when delivering logs to CloudWatch."
  type        = string
  default     = null
  nullable    = true
}

variable "event_selectors" {
  description = <<EOT
List of event selector objects. Each item shape:
{
  read_write_type           = string  # All, ReadOnly, WriteOnly
  include_management_events = bool
  data_resources            = optional(list(object({
    type   = string
    values = list(string)
  })))
}
EOT
  type = list(object({
    read_write_type           = string
    include_management_events = bool
    data_resources = optional(list(object({
      type   = string
      values = list(string)
    })), [])
  }))
  default = []
}

variable "advanced_event_selectors" {
  description = "Optional advanced event selectors (mutually exclusive with event_selectors). Pass-through to aws_cloudtrail."
  type        = any
  default     = []
}
