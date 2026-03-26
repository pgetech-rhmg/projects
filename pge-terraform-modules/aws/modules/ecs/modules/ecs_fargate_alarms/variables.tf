
variable "cluster_name" {
  description = "Enter the name of the cluster."
  type        = string
}

variable "service_name" {
  description = "Enter the name of the service to be monitored."
  type        = string
}

variable "lb_arn_suffix" {
  description = "Enter the lb_arn_suffix to monitor"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# List of actions to trigger when alerts are sent
variable "alert_actions" {
  description = "List of ARN of action to take on alarms, e.g. SNS topics"
  type        = list(any)
  default     = []
}

# CPU Alert Threshold
variable "cpu_alert_threshold" {
  description = "Threshold which will trigger a alert when the cpu crosses"
  type        = number
  default     = "80"
}

# Memory Alert Threshold
variable "memory_alert_threshold" {
  description = "Threshold which will trigger a alert when the memory crosses"
  type        = number
  default     = "80"
}

variable "HTTPCode_ELB_5XX_threshold" {
  type        = string
  description = "Threshold for ELB 5XX alert"
  default     = "25"
}
