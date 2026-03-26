variable "alarm_name" {
  type        = string
  description = "Domain name or ip address of checking service."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
}

variable "alert_type_name" {
  type        = string
  default     = "other"
  description = "Alert_Type"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Alarm emitter."
}

variable "metric_name" {
  type        = string
  default     = ""
  description = "Name of the metric."
}
variable "comparison_operator" {
  type        = string
  default     = ""
  description = "Comparison operator."
}

variable "evaluation_periods" {
  type        = string
  default     = ""
  description = "Evaluation periods."
}

variable "period" {
  type        = string
  default     = ""
  description = "Period."
}

variable "statistic" {
  type        = string
  default     = ""
  description = "Statistic."
}

variable "threshold" {
  type        = string
  default     = ""
  description = "Threshold."
}

variable "unit" {
  type    = string
  default = ""
}

variable "dimensions" {
  type    = map(any)
  default = {}
}


variable "insufficient_data_actions" {
  type    = list(any)
  default = []
}

variable "treat_missing_data" {
  type    = string
  default = ""
}



### SNS Topic related variables
variable "sns_subscription_email_address_list" {
  type        = list(string)
  default     = []
  description = "List of email addresses"
}

variable "sns_topic" {
  type        = string
  description = "SNS TOPIC arn to be passed to receive the alerts"
}




