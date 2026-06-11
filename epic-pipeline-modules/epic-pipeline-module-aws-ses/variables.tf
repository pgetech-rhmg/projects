# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the SES configuration set."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

# Optional inputs
variable "custom_configuration_set_name" {
  description = "Full configuration set name override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "reputation_metrics_enabled" {
  description = "Whether reputation metrics (bounce / complaint rates) are emitted to CloudWatch."
  type        = bool
  default     = true
}

variable "sending_enabled" {
  description = "Whether email sending is enabled for this configuration set."
  type        = bool
  default     = true
}

variable "custom_redirect_domain" {
  description = "Custom domain used in click-tracking redirects. Empty disables custom tracking."
  type        = string
  default     = ""
}

variable "event_destination" {
  description = <<EOT
Optional CloudWatch event destination wired to this configuration set. Object shape:
{
  name              = string                        # required
  enabled           = bool                          # default true
  matching_types    = list(string)                  # required, e.g. ["bounce", "complaint", "delivery", "send", "reject", "deliveryDelay"]
  default_value     = string                        # required for cloudwatch destination
  dimension_name    = string                        # required for cloudwatch destination
  value_source      = string                        # required for cloudwatch destination (messageTag, emailHeader, linkTag)
}
EOT
  type = object({
    name           = string
    enabled        = optional(bool, true)
    matching_types = list(string)
    default_value  = string
    dimension_name = string
    value_source   = string
  })
  default  = null
  nullable = true
}
