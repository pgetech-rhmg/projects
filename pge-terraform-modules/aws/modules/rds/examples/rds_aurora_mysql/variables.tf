variable "user" {
  type        = string
  description = "User id for aws session"
}
variable "aws_role" {
  type        = string
  description = "Unique name for the role"
}
variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
/***********************************************************RDS db cluster variables*********************************************/
variable "identifier" {
  description = "(Required) The identifier for the RDS aurora cluster resources."
  type        = string
}


variable "kms_role" {
  type        = string
  description = "KMS role for the encryption"
}

variable "kms_name" {
  type        = string
  description = "Unique name for kms for encrypting the secretsmanager"
}

variable "kms_description" {
  type        = string
  default     = "KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "engine_mode" {
  description = "(Optional) The database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), multimaster, parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless."
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "(Optional) The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value. For example with Aurora MySQL 2, a potential value for this argument is 5.7.mysql_aurora.2.03.2. The value can contain a partial version where supported by the API. The actual engine version used is returned in the attribute engine_version_actual, , see Attributes Reference below."
  type        = string
  default     = null
}

variable "database_name" {
  description = "(Optional) Name for an automatically created database on cluster creation. Must be lowercase, begin with a letter, and alphanumeric(There are different naming restrictions per database engine: RDS Naming Constraints)."
  type        = string
  default     = null
}


variable "allow_major_version_upgrade" {
  description = "(Optional) Enable to allow major engine version upgrades when changing engine versions. Defaults to false."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "(Optional) If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
  type        = bool
  default     = false
}

variable "enable_http_endpoint" {
  description = "(Optional) Enable HTTP endpoint (data API). Only valid when engine_mode is set to serverless."
  type        = bool
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL)."
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "final_snapshot_identifier" {
  description = "(Optional) The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "master_username" {
  description = "(Required unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the secondary cluster of a global database) Username for the master DB user. Please refer to the RDS Naming Constraints. This argument does not support in-place updates and cannot be changed during a restore from snapshot."
  type        = string
  default     = null
}

variable "master_password" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
  default     = null
  validation {
    condition     = var.master_password == null ? true : length(var.master_password) >= 16
    error_message = "Must be at least 16 characters in length."
  }
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided"
  type        = bool
  default     = false
}


variable "preferred_backup_window" {
  description = "(Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00"
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "(Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = bool
  default     = false
}



/***********************************************************RDS db_cluster_instance variables*********************************************/


variable "instance_class" {
  description = "(Required) The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details.?"
  type        = string

}
variable "monitoring_interval" {
  description = "(Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 1
  validation {
    condition     = var.monitoring_interval > 0
    error_message = "Monitoring interval must be greater than 0."
  }
}


variable "performance_insights_enabled" {
  description = "(Optional) Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "(Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance_insights_kms_key_id, performance_insights_enabled needs to be set to true."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "(Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance_insights_retention_period, performance_insights_enabled needs to be set to true. Defaults to 7."
  type        = number
  default     = 7
}

variable "cluster_performance_insights_enabled" {
  description = "(Optional) Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "cluster_performance_insights_kms_key_id" {
  description = "(Optional) ARN for the KMS key to encrypt Performance Insights data. When specifying performance_insights_kms_key_id, performance_insights_enabled needs to be set to true."
  type        = string
  default     = null
}

variable "cluster_performance_insights_retention_period" {
  description = "(Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance_insights_retention_period, performance_insights_enabled needs to be set to true. Defaults to '7'."
  type        = number
  default     = 7
}


variable "db_cluster_instance_tags" {
  description = "Additional tags for the DB instance"
  type        = map(string)
  default     = {}
}

variable "cluster_instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1
}
/***********************************************************RDS db_cluster_parameter_group variables*********************************************/

variable "cluster_parameters" {
  description = "A list of DB cluster parameter maps to apply.  Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-cluster-parameters after initial creation of the group."
  type        = list(map(string))
  default     = []
}

variable "db_cluster_parameter_group_tags" {
  description = "Additional tags for the  DB cluster parameter group"
  type        = map(string)
  default     = {}
}
/**********************************************************security group variables*************************************/

variable "security_group_tags" {
  description = "Additional tags for the RDS security group"
  type        = map(string)
  default     = {}
}

/***********************************************************RDS db parameter group variables*********************************************/

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "db_parameter_group_tags" {
  description = "Additional tags for the  DB parameter group"
  type        = map(string)
  default     = {}
}
/***********************************************************RDS db subnet group variables*********************************************/

variable "db_subnet_group_tags" {
  description = "Additional tags for the DB subnet group"
  type        = map(string)
  default     = {}
}

/*******************************************Additional Tags by resource*******************************************/
variable "tags" {
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags."
  type        = map(string)
  default     = {}
}

#ssm_parameter

variable "ssm_description" {
  type        = string
  default     = null
  description = "Description of the parameter"
}


variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
}