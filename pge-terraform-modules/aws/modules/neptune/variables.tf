#variables for cluster
variable "engine_version" {
  description = "(Optional) The neptune engine version."
  type        = string
  default     = "1.1.0.0"
  validation {
    condition     = contains(["1.1.0.0"], var.engine_version)
    error_message = "Error! engine version value must be '1.1.0.0'!"
  }
}

variable "enable_cloudwatch_logs_exports" {
  description = "(Optional) A list of the log types this DB cluster is configured to export to Cloudwatch Logs. Currently only supports audit."
  type        = list(string)
  default     = ["audit"]
  validation {
    condition     = alltrue([for i in var.enable_cloudwatch_logs_exports : contains(["audit"], i)])
    error_message = "Error! Valid value for enable_cloudwatch_logs_exports is 'audit'!"
  }
}

variable "allow_major_version_upgrade" {
  description = "(Optional) Specifies whether upgrades between different major versions are allowed. You must set it to true when providing an engine_version parameter that uses a different major version than the DB cluster's current version. Default is false."
  type        = bool
  default     = false
}

variable "port" {
  description = "(Optional) The port on which the Neptune accepts connections. Default is 8182."
  type        = number
  default     = 8182
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false."
  type        = bool
  default     = false
}

variable "replication_source_identifier" {
  description = "(Optional) ARN of a source Neptune cluster or Neptune instance if this Neptune cluster is to be created as a Read Replica."
  type        = string
  default     = null
}

variable "cluster_identifier" {
  description = "The cluster identifier."
  type        = string
}

variable "availability_zones" {
  description = " (Optional) A list of EC2 Availability Zones that instances in the Neptune cluster can be created in."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the Cluster"
  type        = list(string)
  validation {
    condition     = alltrue([for i in var.vpc_security_group_ids : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of vpc_security_group_ids, value should be in form of 'sg-xxxxxxxx'!"
  }
}

variable "iam_roles" {
  description = "(Optional) A List of ARNs for the IAM roles to associate to the Neptune Cluster."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for i in var.iam_roles : can(regex("^arn:aws:iam::\\w+", i)) if i != ""])
    error_message = "Error! Provide list of iam role arns, value should be in form of 'arn:aws:iam::xxxxxx'!"
  }
}

variable "kms_key_arn" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_arn, storage_encrypted needs to be set to true."
  type        = string
}

variable "neptune_subnet_group_name" {
  description = "A Neptune subnet group to associate with this Neptune instance."
  type        = string
}

variable "neptune_cluster_parameter_group_name" {
  description = "(Optional) A cluster parameter group to associate with the cluster."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "(Optional) The days to retain backups for."
  type        = number
  default     = 15
  validation {
    condition     = alltrue([var.backup_retention_period >= 15])
    error_message = "Error! Backup retention period must be 15 or more"
  }
}

variable "preferred_backup_window" {
  description = "(Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter. Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00"
  type        = any
  default     = null
}

variable "preferred_maintenance_window" {
  description = "(Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
  type        = any
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "(Optional) If set to true, tags are copied to any snapshot of the DB cluster that is created."
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "(Optional) The name of your final Neptune snapshot when this Neptune cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final Neptune snapshot is created before the Neptune cluster is deleted. If true is specified, no Neptune snapshot is created. If false is specified, a Neptune snapshot is created before the Neptune cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "(Optional) Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a Neptune cluster snapshot, or the ARN when specifying a Neptune snapshot."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "(Optional) A value that indicates whether the DB cluster has deletion protection enabled.The database can't be deleted when deletion protection is enabled. By default, deletion protection is disabled."
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours."
  type        = map(string)
  default     = {}
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  tags    = var.tags
  version = "0.1.2"
}