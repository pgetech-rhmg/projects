# Variables for ecs account setting default

variable "ecs_account_name" {
  description = "Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights."
  type        = string
  validation {
    condition     = contains(["serviceLongArnFormat", "taskLongArnFormat", "containerInstanceLongArnFormat", "awsvpcTrunking", "containerInsights"], var.ecs_account_name)
    error_message = "Valid values for ecs account name are  serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights."
  }
}

variable "ecs_account_setting_value" {
  description = "State of the setting. Valid values are enabled and disabled."
  type        = string
  validation {
    condition     = contains(["enabled", "disabled"], var.ecs_account_setting_value)
    error_message = "Valid values for ecs account setting value are  enabled and disabled."
  }
}