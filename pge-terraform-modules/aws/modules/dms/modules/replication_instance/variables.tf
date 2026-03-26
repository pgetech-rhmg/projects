variable "replication_subnet_group_description" {
  type        = string
  description = "The description for the subnet group."
}

variable "replication_subnet_group_id" {
  type        = string
  description = "The name for the replication subnet group. This value is stored as a lowercase string."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of the EC2 subnet IDs for the subnet group."
}

#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#variables for replication instance
variable "instance_allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance."
  default     = null
}

variable "instance_apply_immediately" {
  type        = bool
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource."
  default     = null
}

variable "instance_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window."
  default     = null
}

variable "instance_allow_major_version_upgrade" {
  type        = bool
  description = "(Optional, Default: false) Indicates that major version upgrades are allowed."
  default     = false
}

variable "instance_availability_zone" {
  type        = string
  description = "The EC2 Availability Zone that the replication instance will be created in."
  default     = null
}

variable "instance_engine_version" {
  type        = string
  description = "The engine version number of the replication instance."
  default     = null
}

variable "instance_multi_az" {
  type        = bool
  description = "Specifies if the replication instance is a multi-az deployment. You cannot set the availability_zone parameter if the multi_az parameter is set to true."
  default     = null
}

variable "instance_kms_key_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) for the KMS key that will be used to encrypt the connection parameters."
  default     = null
}

variable "instance_preferred_maintenance" {
  type        = string
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)."
  default     = null
}

variable "instance_publicly_accessible" {
  type        = bool
  description = "Specifies the accessibility options for the replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address."
  default     = null
}

variable "instance_replication_instance_class" {
  type        = string
  description = "The compute and memory capacity of the replication instance as specified by the replication instance class."
}

variable "instance_replication_id" {
  type        = string
  description = "The replication instance identifier."
  validation {
    condition = alltrue([
      length(var.instance_replication_id) >= 1 && length(var.instance_replication_id) <= 63
    ])
    error_message = "Must contain from 1 to 63 alphanumeric characters or hyphens. and can contain only the following characters:a-z,A-Z,0-9,_(underscore),-(dash),.(dot)."
  }
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to be used with the replication instance. The VPC security groups must work with the VPC containing the replication instance."
  default     = null
}

variable "timeouts_create" {
  description = " Used for Creating Instances"
  type        = string
  default     = "40m"
}

variable "timeouts_delete" {
  description = "Used for destroying databases"
  type        = string
  default     = "80m"
}

variable "timeouts_update" {
  description = "Used for Database modifications"
  type        = string
  default     = "80m"
}