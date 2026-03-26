module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

### variables for restore testing ###

variable "restore_plan_name" {
  description = "Name of the restore plan  to create"
  type        = string
  validation {
    condition     = (length(var.restore_plan_name) > 0)
    error_message = "Plan name cannot be empty."
  }
}

variable "include_vaults" {
  description = "An array of vaults to be included."
  type        = list(string)
  default     = []
}

variable "exclude_vaults" {
  description = "An array of vaults to avoid."
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "A CRON expression specifying when AWS Backup initiates a restore testing plan"
  type = string
  default = "cron(0 5 ? * * *)" # Daily 5 AM UTC
}

variable "selection_window_days" {
  description = "The number of days to look back for recovery points"
  type = number
  default = 30
}

variable "schedule_expression_timezone" {
  description = "Timezon for the schedules expression"
  type = string
  default = "UTC"
}

variable "start_window_hours" {
  description = "The number of hours after a restore test is scheduled before a job will be cancelled if not started"
  type = number
  default = 24
}

variable "algorithm" {
  description = "algorithm used for selecting recovery points"
  type = string
  default = "RANDOM_WITHIN_WINDOW"
}

variable "recovery_point_types" {
  description = "types of recovery points to include in the selection."
  type        = list(string)
  default     = ["SNAPSHOT"]
}

variable "resource_selection_name" {
  description = "The name of the backup restore testing selection."
  type = string
}

variable "resource_type" {
  description = "The type of the protected resource."
  type = string
}

variable "resource_role_arn" {
  description = "The ARN of the IAM role."
  type = string
}

variable "resource_arns" {
  description = " The ARNs for the protected resources."
  type        = list(string)
}

variable "protected_resource_conditions" {
  description = "Protected resource condition for the resource testing selection"
  type = list(object({
     string_equals = optional(list(object({
      key = string
      value = string
     })))
     string_not_equals = optional(list(object({
      key = string
      value = string
     })))
  }))
  default = null
}

variable "validation_window_hours" {
  description = "The amount of hours available to run a validation script on the data"
  type = number
  default = 24
}
variable enable_restore_metadata_overrides {
  type = bool
  description = "Enable restore testing overrides"
  default = false
}

variable "restore_metadata_overrides" {
  description = " Override certain restore metadata keys"
  type = map(string)
  default = {}
}
