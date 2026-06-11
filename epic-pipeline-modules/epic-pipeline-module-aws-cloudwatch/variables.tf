# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming CloudWatch resources."
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

# Log group inputs
variable "log_group_name" {
  description = "Final segment of the log group path. Combined into /pge-epic/<app>/<env>/<log_group_name> unless custom_log_group_name is provided. Set to null to skip log group creation."
  type        = string
  default     = null
  nullable    = true
}

variable "custom_log_group_name" {
  description = "Full log group path override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "retention_in_days" {
  description = "Log group retention in days. SAF-accepted buckets: 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653. NFR Tool standard: 90; audit-relevant: 180."
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_in_days)
    error_message = "retention_in_days must be a CloudWatch-accepted retention bucket."
  }
}

variable "log_group_kms_key_id" {
  description = "KMS Key ARN for log group encryption. Required for Confidential / audit-relevant log groups per SAF."
  type        = string
  default     = null
  nullable    = true
}

variable "log_group_skip_destroy" {
  description = "If true, the log group is preserved on terraform destroy."
  type        = bool
  default     = false
}

# Metric filter inputs
variable "metric_filters" {
  description = <<EOT
List of metric filter objects to attach to the log group. Each item shape:
{
  name              = string         # required, filter name
  pattern           = string         # required, log filter pattern
  metric_name       = string         # required
  metric_namespace  = string         # required, e.g., "NfrTool/<env>"
  metric_value      = string         # required, e.g., "1"
  default_value     = optional(string)
  unit              = optional(string)
}
EOT
  type = list(object({
    name             = string
    pattern          = string
    metric_name      = string
    metric_namespace = string
    metric_value     = string
    default_value    = optional(string)
    unit             = optional(string)
  }))
  default = []
}

# Dashboard inputs
variable "custom_dashboard_name" {
  description = "Full dashboard name override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "dashboard_body" {
  description = "JSON-encoded dashboard body. When null, no dashboard is created."
  type        = string
  default     = null
  nullable    = true
}
