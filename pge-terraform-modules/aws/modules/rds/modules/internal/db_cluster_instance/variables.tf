variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}
variable "identifier" {
  description = "The identifier for the cluster instance."
  type        = string
}

variable "custom_instance_names" {
  description = "(Optional) List of custom names for cluster instances. If provided, the list length must match cluster_instance_count. If not provided, defaults to identifier-0, identifier-1, etc. for backward compatibility."
  type        = list(string)
  default     = []
}

variable "cluster_identifier" {
  description = "(Required, Forces new resource) The identifier of the aws_rds_cluster in which to launch this instance."
  type        = string
}

variable "engine" {
  description = "(Optional, Forces new resource) The name of the database engine to be used for the RDS instance. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide."
  type        = string
  default     = null
}

variable "engine_version" {
  description = "(Optional) The database engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details.?"
  type        = string
}
#Todo: test validation
variable "publicly_accessible" {
  description = "(Optional) Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property."
  type        = bool
  default     = false
  validation {
    condition     = var.publicly_accessible == false
    error_message = "DB Cluster Instance cannot be publically accessible.  Please set to false."
  }
}

variable "db_subnet_group_name" {
  description = "(Required if publicly_accessible = false, Optional otherwise, Forces new resource) A DB subnet group to associate with this DB instance. NOTE: This must match the db_subnet_group_name of the attached aws_rds_cluster."
  type        = string
}

variable "db_parameter_group_name" {
  description = "(Optional) The name of the DB parameter group to associate with this instance."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false."
  type        = bool
  default     = false
}

#Todo: Require for the rds modules
variable "monitoring_role_arn" {
  description = "(Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the AWS Documentation what IAM permissions are needed to allow Enhanced Monitoring for RDS Instances."
  type        = string
  default     = null
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
}

variable "preferred_backup_window" {
  description = "(Optional) The daily time range during which automated backups are created if automated backups are enabled. Eg: '04:00-09:00'."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "(Optional) The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:m'. Eg: 'Mon:00:00-Mon:03:00'."
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
  description = "(Optional) Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years). When specifying performance_insights_retention_period, performance_insights_enabled needs to be set to true. Defaults to '7'."
  type        = number
  default     = 7
}

variable "copy_tags_to_snapshot" {
  description = "(Optional, boolean) Indicates whether to copy all of the user-defined tags from the DB instance to snapshots of the DB instance. Default true."
  type        = bool
  default     = true
}

variable "ca_cert_identifier" {
  description = "(Optional) The identifier of the CA certificate for the DB instance."
  type        = string
  default     = null
}

variable "instance_timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to `aws_db_cluster_instance`."
  type        = map(string)
  default = {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}
variable "cluster_instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1
}
variable "tags" {
  description = "(Optional) A map of tags to assign to the instance. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined."
  type        = map(string)
  default     = {}

}

# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
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

variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
}

variable "disk_queue_depth_too_high_threshold" {
  type        = string
  default     = "64"
  description = "Alarm threshold for the 'highDiskQueueDepth' alarm"
}

variable "disk_free_storage_space_too_low_threshold" {
  type        = string
  default     = "10000000000" // 10 GB
  description = "Alarm threshold for the 'lowFreeStorageSpace' alarm"
}
variable "disk_burst_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowEBSBurstBalance' alarm"
}

variable "memory_freeable_too_low_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'lowFreeableMemory' alarm"
}

variable "memory_swap_usage_too_high_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'highSwapUsage' alarm"
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

variable "create_anomaly_alarm" {

  type        = bool
  default     = true
  description = "Whether or not to create the fairly noisy anomaly alarm.  Default is to create it (for backwards compatible support), but recommended to disable this for non-production databases"
}