variable "dashboard_name" {
  description = "New dashboard name"
  type        = string
  default     = "infrastracture-metrics"
}

variable "services" {
  description = "Services list that would be used to build wdgets inside dashboard"
  type = list(object({
    cluster_name  = string
    service_name  = string
    widget_prefix = string
    lb_arn_suffix = string
  }))
  default = []
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}