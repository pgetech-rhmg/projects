variable "ses_configuration_set_name" {
  description = "Name of the configuration set."
  type        = string
}

variable "reputation_metrics_enabled" {
  description = "Whether or not Amazon SES publishes reputation metrics for the configuration set, such as bounce and complaint rates, to Amazon CloudWatch. The default value is false"
  type        = bool
  default     = false
}

variable "sending_enabled" {
  description = "Whether email sending is enabled or disabled for the configuration set. The default value is true."
  type        = bool
  default     = true
}

variable "custom_redirect_domain" {
  description = "Custom subdomain that is used to redirect email recipients to the Amazon SES event tracking domain. "
  type        = string
  default     = ""
}

