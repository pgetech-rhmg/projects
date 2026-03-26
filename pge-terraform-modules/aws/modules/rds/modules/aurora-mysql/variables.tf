
variable "random_password_length" {
  description = "(Optional) Length of random password to create. (default: 16)"
  type        = number
  default     = 16
  validation {
    condition     = var.random_password_length >= 16
    error_message = "Must be at least 16 characters in length."
  }
}


/***********************************************************RDS db cluster instance variables*********************************************/
variable "identifier" {
  description = "(Optional, Forces new resource) The identifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details.?"
  type        = string
}


variable "monitoring_role_arn" {
  description = "(Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the AWS Documentation what IAM permissions are needed to allow Enhanced Monitoring for RDS Instances."
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

variable "promotion_tier" {
  description = "(Optional) Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer."
  type        = number
  default     = 0
}

variable "availability_zone" {
  description = "(Optional, Computed, Forces new resource) The EC2 Availability Zone that the DB instance is created in. See docs about the details."
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "(Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true."
  type        = bool
  default     = true
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
variable "ca_cert_identifier" {
  description = "(Optional) The identifier of the CA certificate for the DB instance."
  type        = string
  default     = null
}

variable "instance_timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to aws_db_cluster_instance."
  type        = map(string)
  default = {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
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

variable "create_anomaly_alarm" {

  type        = bool
  default     = true
  description = "Whether or not to create the fairly noisy anomaly alarm.  Default is to create it (for backwards compatible support), but recommended to disable this for non-production databases"
}
/***********************************************************RDS DB Cluster variables*********************************************/
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

variable "availability_zones" {
  description = "(Optional) A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply. It is recommended to specify 3 AZs or use the lifecycle configuration block ignore_changes argument if necessary."
  type        = list(string)
}

variable "backup_retention_period" {
  description = "(Optional) The days to retain backups for. Default 15"
  type        = number
  default     = 15
  validation {
    condition     = var.backup_retention_period >= 15
    error_message = "Must be at least 15 days."
  }
}

variable "database_name" {
  description = "(Optional) Name for an automatically created database on cluster creation. Must be lowercase alphanumeric(There are different naming restrictions per database engine: RDS Naming Constraints)."
  type        = string
  default     = null
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

variable "engine" {
  description = "(Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters)."
  type        = string
  default     = "aurora-mysql"
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


variable "final_snapshot_identifier" {
  description = "(Optional) The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "global_cluster_identifier" {
  description = "(Optional) The global cluster identifier specified on aws_rds_global_cluster."
  type        = string
  default     = null
}

variable "enable_global_write_forwarding" {
  description = "(Optional) Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an aws_rds_global_cluster's primary cluster. See the Aurora Userguide documentation for more information."
  type        = bool
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  type        = string

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
variable "master_username" {
  description = "(Required unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the secondary cluster of a global database) Username for the master DB user. Please refer to the RDS Naming Constraints. This argument does not support in-place updates and cannot be changed during a restore from snapshot."
  type        = string
  default     = null
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the ,master user password in Secrets Manager. Cannot be set if password is provided"
  type        = bool
  default     = false
}

variable "master_user_secret_kms_key_id" {
  description = "The ARN for the KMS encryption key for manage master user password. If creating an encrypted replica, set this to the destination KMS ARN."
  type        = string
  default     = null
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

variable "replication_source_identifier" {
  description = "(Optional) ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. If DB Cluster is part of a Global Cluster, use the lifecycle configuration block ignore_changes argument to prevent Terraform from showing differences for this argument instead of configuring this value."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "(Optional) Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = null
}

variable "source_region" {
  description = "(Optional) The source region for an encrypted replica DB cluster."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the DB cluster. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
  default     = {}
}



/************************************************RDS security_group variables******************************************/

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
}

variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
}

variable "security_group_ingress_rules" {
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
  description = "Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule."
}

variable "security_group_egress_rules" {
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
  description = "Configuration block for for nested security groups egress rules. Can be specified multiple times for each egress rule."
}
variable "security_group_tags" {
  description = "Additional tags for the RDS security group"
  type        = map(string)
  default     = {}
}

/***********************************************************RDS DB Cluster Parameter Group variables*********************************************/

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


/***********************************************************RDS DB Paramater Group variables*********************************************/

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = null
}

variable "parameters" {
  description = "A list of DB parameter maps to apply."
  type        = list(map(string))
  default     = []
}

variable "db_parameter_group_tags" {
  description = "A mapping of tags to assign to the db parameter group resource."
  type        = map(string)
  default     = {}
}

/***********************************************************RDS Cloudwatch Metric alarm variables*********************************************/
# Cloudwatch metric alarms
variable "evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}
variable "statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}
variable "cpu_utilization_too_high_threshold" {
  type        = string
  default     = "90"
  description = "Alarm threshold for the 'highCPUUtilization' alarm"
}
variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
}
variable "actions_alarm" {
  type        = list(any)
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}

variable "actions_ok" {
  type        = list(any)
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}
variable "anomaly_period" {
  type        = string
  default     = "600"
  description = "The number of seconds that make each evaluation period for anomaly detection."
}

variable "anomaly_band_width" {
  type        = string
  default     = "2"
  description = "The width of the anomaly band, default 2.  Higher numbers means less sensitive."
}


variable "disk_queue_depth_too_high_threshold" {
  type        = string
  default     = "64"
  description = "Alarm threshold for the highDiskQueueDepth alarm"
}

variable "disk_free_storage_space_too_low_threshold" {
  type        = string
  default     = "10000000000" // 10 GB
  description = "Alarm threshold for the lowFreeStorageSpace alarm"
}
variable "disk_burst_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the lowEBSBurstBalance alarm"
}

variable "memory_freeable_too_low_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the lowFreeableMemory alarm"
}

variable "memory_swap_usage_too_high_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the highSwapUsage alarm"
}


/*********************************************RDS DB Subnet Group variables*********************************************/

variable "subnet_ids" {
  description = "A list of VPC subnet IDs."
  type        = list(string)
  default     = []
}

variable "db_subnet_group_tags" {
  description = "A mapping of tags to assign to the db subnet group resource."
  type        = map(string)
  default     = {}
}


#ssm_parameter

variable "ssm_description" {
  type        = string
  default     = null
  description = "Description of the parameter"
}


variable "create_ssm_parameter" {
  type        = bool
  default     = false
  description = "(Optional) Whether to create SSM parameter for the master password. Default is false."
}

variable "key_id" {
  description = "KMS key ID or ARN for encrypting a SecureString."
  default     = null
  type        = string
}


/***********************************************************RDS  variables*********************************************/
# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"

  tags = var.tags
}
variable "scaling_configuration" {
  description = "(Optional) Map of nested attribute with scaling properties. Only valid when engine_mode is set to serverless."
  type        = map(string)
  default     = {}
}


variable "serverlessv2_scaling_configuration" {
  description = "(Optional) Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned`"
  type        = map(string)
  default     = {}
}

#allocated_storage,storage_type,iops should not be necessary configurations for Aurora.
variable "allocated_storage" {
  description = "(Optional) The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster)."
  type        = string
  default     = null
}

variable "storage_type" {
  description = "(Optional) Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: io1, Default: io1."
  type        = string
  default     = null
}

variable "iops" {
  description = "(Optional) The amount of provisioned IOPS. Setting this implies a storage_type of io1."
  type        = number
  default     = null
}


variable "custom_instance_names" {
  description = "(Optional) List of custom names for cluster instances. If provided, the list length must match cluster_instance_count. If not provided, defaults to identifier-0, identifier-1, etc. for backward compatibility."
  type        = list(string)
  default     = []
}

