variable "efs_one_zone_az" {
  description = "The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The arn for the kms encryption key"
  type        = string
  default     = null
}


variable "performance_mode" {
  description = "The file system performance mode"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Error! Valid values for performance mode are (generalPurpose, maxIO). Please select on these as performance_mode parameter."
  }
}

variable "transition_to_ia" {
  description = "Indicates how long it takes to transition files to the IA storage class"
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.transition_to_ia == null,
      var.transition_to_ia == "AFTER_7_DAYS",
      var.transition_to_ia == "AFTER_14_DAYS",
      var.transition_to_ia == "AFTER_30_DAYS",
      var.transition_to_ia == "AFTER_60_DAYS",
      var.transition_to_ia == "AFTER_90_DAYS"
    ])
    error_message = "Error! Valid values for transition to ia are (AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, or AFTER_90_DAYS). Please select on these as transition_to_ia parameter."
  }
}

variable "enable_transition_to_primary_storage_class" {
  description = "Input from the user to enable or disable transition_to_primary_storage_class"
  type        = bool
  default     = false
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Error! Valid values for throughput mode are (bursting, provisioned). Please select on these as throughput_mode parameter."
  }
}

variable "provisioned_throughput" {
  description = "The throughput provisioned for the file system. Only applicable with throughput_mode set to provisioned"
  type        = number
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign resources for EFS"
  type        = map(string)

}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "posix_user_file_system" {
  description = "Operating system user and group applied to all file system requests made using the access point."
  type        = bool
  default     = false
}

variable "posix_user_gid" {
  description = "POSIX group ID used for all file system operations using this access point."
  type        = number
  default     = null
}

variable "posix_user_secondary_gids" {
  description = "Secondary POSIX group IDs used for all file system operations using this access point."
  type        = list(number)
  default     = null
}

variable "posix_user_uid" {
  description = "POSIX user ID used for all file system operations using this access point."
  type        = number
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet to add the mount target"
  type        = list(string)
}

variable "security_groups" {
  description = "A list of up to 5 VPC security group IDs in effect for the mount target."
  type        = list(string)
}

variable "policy" {
  description = "Valid JSON document representing a resource policy"
  type        = any
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON."
  }
}

variable "backup_status" {
  description = "EFS Backup Status ENABLED or DISABLED"
  type        = string
  default     = "DISABLED"
}

variable "root_directory" {
  description = "Root directory for the access point"
  type        = list(any)
  default     = [{ path = "/" }]
}