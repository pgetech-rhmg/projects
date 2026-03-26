variable "name" {
  description = "The name of the AppConfig deployment strategy."
  type        = string
  default     = "appconfig strategy name"
}

variable "description" {
  description = "The description of the AppConfig deployment strategy."
  type        = string
  default     = "appconfig strategy desc"
}

variable "deployment_duration" {
  description = "The duration of the AppConfig deployment strategy. 0 <= x <= 1440"
  type        = number
  default     = 1
}

variable "replicate_to" {
  description = "Where to save the deployment strategy. Either NONE or SSM_DOCUMENT"
  type        = string
  default     = "NONE"
}

variable "growth_type" {
  description = "Algorithm used to define how percentage grows over time. Either LINEAR or EXPONENTIAL. Default LINEAR"
  type        = string
  default     = "LINEAR"
}

variable "growth_factor" {
  description = "Percentage of targets to receive a deployed configuration during each interval. 1 <= x <= 100"
  type        = number
  default     = 100
}

variable "bake_time" {
  description = "Amount of time AppConfig monitors for alarms before consdiering the deployment complete and no longer eligble for automatic roll back. 0 <= x <= 1440"
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
