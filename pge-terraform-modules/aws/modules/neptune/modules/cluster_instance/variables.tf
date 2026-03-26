#Variables for tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  tags    = var.tags
  version = "0.1.2"
}

#Variables for cluster instance
variable "engine_version" {
  description = "(Optional) The neptune engine version."
  type        = string
  default     = "1.1.0.0"
  validation {
    condition     = contains(["1.1.0.0"], var.engine_version)
    error_message = "Error! engine version value must be '1.1.0.0'!"
  }
}

variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Specifies whether any instance modifications are applied immediately, or during the next maintenance window. Default is false."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The EC2 Availability Zone that the neptune instance is created in."
  type        = string
  default     = null
}

variable "cluster_identifier" {
  description = "The identifier of the aws_neptune_cluster in which to launch this instance."
  type        = string
}

variable "identifier" {
  description = "The identifier for the neptune instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance class to use."
  type        = string
}

variable "neptune_subnet_group_name" {
  description = "A subnet group to associate with this neptune instance."
  type        = string
}

variable "neptune_parameter_group_name" {
  description = "The name of the neptune parameter group to associate with this instance."
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections. Defaults to 8182."
  type        = number
  default     = 8182
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled. Eg: 04:00-09:00."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00."
  type        = string
  default     = null
}

variable "promotion_tier" {
  description = "Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer."
  type        = number
  default     = 0
}

variable "cluster_instance_timeouts" {
  description = "The cluster instance timeouts should be in the format 90m for 90 minutes, 10s for ten seconds, or 2h for two hours."
  type        = list(map(string))
  default = [{
    create = "90m"
    update = "90m"
    delete = "90m"
  }]
}