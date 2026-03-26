variable "cluster_apply_immediately" {
  description = "Specifies whether any cluster or database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "cluster_availability_zones" {
  description = "A list of EC2 Availability Zones that instances in the DB cluster can be created in."
  type        = list(string)
  default     = []
}

variable "cluster_backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 15
  validation {
    condition = (
      var.cluster_backup_retention_period >= 15 &&
    var.cluster_backup_retention_period <= 35)
    error_message = "Error! Set a value from 15 to 35."
  }
}

variable "cluster_identifier" {
  description = "The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
  type        = string
}

variable "db_subnet_group_name" {
  description = "A DB subnet group to associate with this DB instance."
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster."
  type        = string
  default     = null
}

variable "cluster_deletion_protection" {
  description = "A value that indicates whether the DB cluster has deletion protection enabled. The database can't be deleted when deletion protection is enabled."
  type        = bool
  default     = false
}

variable "cluster_enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported."
  type        = list(string)
  default     = ["audit"]
  validation {
    condition = alltrue([
    for cecls in var.cluster_enabled_cloudwatch_logs_exports : contains(["profiler", "audit"], cecls)])
    error_message = "Error! enter a valid value for cluster_enabled_cloudwatch_logs_exports. valid values are profiler and audit."
  }
}

variable "cluster_engine_version" {
  description = "The database engine version. Updating this argument results in an outage."
  type        = string
  default     = "4.0.0"
  validation {
    condition     = contains(["4.0.0", "3.6.0"], var.cluster_engine_version)
    error_message = "Error! cluster engine version value must be '4.0.0', '3.6.0'!."
  }
}

variable "cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster and instance. Defaults to docdb."
  type        = string
  default     = "docdb"
  validation {
    condition     = contains(["docdb"], var.cluster_engine)
    error_message = "Error! cluster engine value must be 'docdb'!."
  }
}

variable "cluster_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "cluster_global_cluster_identifier" {
  description = "The global cluster identifier."
  type        = string
  default     = null
}

variable "cluster_kms_key_id" {
  description = "The ARN for the KMS encryption key."
  type        = string
}

variable "cluster_master_password" {
  description = "(Required unless a snapshot_identifier or unless a global_cluster_identifier is provided when the cluster is the 'secondary' cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
  default     = null
  validation {
    condition     = (var.cluster_master_password == null ? true : ((length(var.cluster_master_password)) >= 8 && (!can(regex("[@/]", var.cluster_master_password)))))
    error_message = "Master password must be at least eight characters long and cannot contain a / (slash), (double quote) or @ (at symbol)."
  }
}

variable "cluster_master_username" {
  description = "(Required unless a snapshot_identifier or unless a global_cluster_identifier is provided when the cluster is the 'secondary' cluster of a global database) Username for the master DB user"
  type        = string
  default     = null
  validation {
    condition     = (var.cluster_master_username == null ? true : (can(regex("^[a-zA-Z][a-zA-Z-_0-9]{1,63}$", var.cluster_master_username))))
    error_message = "Master username must start with a letter and contain 1 to 63 characters."
  }
}

variable "cluster_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "cluster_preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region E.g., 04:00-09:00"
  type        = string
  default     = null
}

variable "cluster_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
  type        = string
  default     = null
}

variable "cluster_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier."
  type        = bool
  default     = false
}

variable "cluster_snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = null
}

variable "cluster_vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the Cluster"
  type        = list(string)
  validation {
    condition     = alltrue([for i in var.cluster_vpc_security_group_ids : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of cluster_vpc_security_group_ids, value should be in form of 'sg-xxxxxxxx'!."
  }
}

variable "cluster_timeouts" {
  description = "aws_docdb_cluster provides the following Timeouts configuration options: create, update, delete"
  type        = map(string)
  default     = {}
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}