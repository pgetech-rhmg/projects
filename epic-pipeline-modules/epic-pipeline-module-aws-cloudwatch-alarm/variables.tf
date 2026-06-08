variable "alarm_name" {
  description = "CloudWatch alarm name."
  type        = string
}

variable "alarm_description" {
  description = "Alarm description."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "CloudWatch metric namespace."
  type        = string
}

variable "metric_name" {
  description = "Metric name."
  type        = string
}

variable "statistic" {
  description = "Statistic to apply (Average, Sum, Minimum, Maximum, SampleCount)."
  type        = string
  default     = "Average"
}

variable "comparison_operator" {
  description = "Comparison operator."
  type        = string
  default     = "GreaterThanThreshold"
}

variable "threshold" {
  description = "Threshold value."
  type        = number
}

variable "period" {
  description = "Evaluation period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate."
  type        = number
  default     = 1
}

variable "dimensions" {
  description = "Metric dimensions."
  type        = map(string)
  default     = {}
}

variable "alarm_actions" {
  description = "List of ARNs to notify on ALARM state."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify on OK state."
  type        = list(string)
  default     = []
}

variable "treat_missing_data" {
  description = "How to treat missing data (missing, ignore, breaching, notBreaching)."
  type        = string
  default     = "missing"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
