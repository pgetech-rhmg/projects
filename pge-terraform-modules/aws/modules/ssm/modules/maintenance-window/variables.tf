module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

#### aws_ssm_maintenance_window ####


variable "maintenance_window_enabled" {
  description = "Whether the maintenance window is enabled."
  type        = bool
  default     = true
}

variable "maintenance_window_allow_unassociated_targets" {
  description = "Whether targets must be registered with the Maintenance Window before tasks can be defined for those targets."
  type        = bool
  default     = false
}

variable "maintenance_window_name" {
  description = "The name of the maintenance window"
  type        = string
}

variable "maintenance_window_description" {
  description = "A description for the maintenance window."
  type        = string
  default     = "PGE targets maintenance window"
}

variable "maintenance_window_duration" {
  description = "The duration of the  maintenence windows in hours"
  type        = number
  default     = 3
}

variable "maintenance_window_cutoff" {
  description = "The number of hours before the end of the  Maintenance Window that Systems Manager stops scheduling new tasks for execution"
  type        = number
  default     = 1
}

variable "maintenance_window_schedule" {
  description = "The schedule of the  Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(15 10 ? * * *)"
}

variable "maintenance_window_schedule_timezone" {
  description = "Timezone for schedule in Internet Assigned Numbers Authority (IANA) Time Zone Database format. For example: America/Los_Angeles, etc/UTC, or Asia/Seoul."
  type        = string
  default     = "US/Pacific"
}

variable "maintenance_window_start_date" {
  description = "Timestamp in ISO-8601 extended format when to begin the maintenance window."
  type        = string
  default     = null
}

variable "maintenance_window_end_date" {
  description = "Timestamp in ISO-8601 extended format when to no longer run the maintenance window."
  type        = string
  default     = null
}

##### aws_ssm_maintenance_window_target ####

variable "maintenance_window_target_resource_type" {
  description = "The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE_GROUP"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.maintenance_window_target_resource_type == null,
      var.maintenance_window_target_resource_type == "INSTANCE",
    var.maintenance_window_target_resource_type == "RESOURCE_GROUP"])
    error_message = "Valid values for target resource types are INSTANCE and RESOURCE_GROUP."
  }
}

variable "maintenance_windows_targets" {
  description = "The map of tags for targetting which EC2 instances will be scaned"
  type = list(object({
    key : string
    values : list(string)
    }
    )
  )
  default = null
}

variable "maintenance_window_target_name" {
  description = "The name of the maintenance window target"
  type        = string
  default     = "EC2Instance"
}

variable "maintenance_window_target_description" {
  description = "The description of the maintenance window target."
  type        = string
  default     = "This is PGE maintenance window target"
}

variable "maintenance_window_target_owner_information" {
  description = "User-provided value that will be included in any CloudWatch events raised while running tasks for these targets in this Maintenance Window."
  type        = string
  default     = null
}