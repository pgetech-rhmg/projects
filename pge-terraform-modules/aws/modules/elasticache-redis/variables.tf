# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for redis cache  

variable "cluster_id" {
  description = "Replication group identifier. This parameter is stored as a lowercase string."
  type        = string
}

variable "replication_group_id" {
  description = "ID of the replication group to which this cluster should belong. If this parameter is specified, the cluster is added to the specified replication group as a read replica; otherwise, the cluster is a standalone primary that is not part of any replication group.Required if engine is not specified) "
  type        = string
  default     = null
}

variable "node_type" {
  description = "The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis"
  type        = string
  validation {
    condition     = can(regex("^cache", var.node_type))
    error_message = "Enter a valid node type."
  }
}
variable "redis_engine_version" {
  description = "Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine_version_actual."
  type        = string
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections. Redis the default port is 6379. "
  type        = number
  default     = 6379
}

variable "slow_logs_log_delivery_destination" {
  description = "Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Slow Log is supported for Redis cache clusters and replication groups using engine version 6.0 onward."
  type        = string
  default     = null
}

variable "slow_logs_log_delivery_destination_type" {
  description = "For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose"
  type        = string
  default     = "cloudwatch-logs"

}

variable "slow_logs_log_delivery_log_format" {
  description = "Valid values are json or text"
  type        = string
  default     = "json"
}

variable "engine_logs_log_delivery_destination" {
  description = "Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.Redis Engine Log is supported for Redis cache clusters and replication groups using engine version 6.2 onward."
  type        = string
  default     = null
}

variable "engine_logs_log_delivery_destination_type" {
  description = "For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose"
  type        = string
  default     = "cloudwatch-logs"
}

variable "engine_logs_log_delivery_log_format" {
  description = "Valid values are json or text"
  type        = string
  default     = "json"
}

variable "apply_immediately" {
  description = "Whether any database modifications are applied immediately, or during the next maintenance window.When you change an attribute, such as num_cache_nodes, by default it is applied in the next maintenance window. Because of this, Terraform may report a difference in its planning phase because the actual modification has not yet taken place. You can use the apply_immediately flag to instruct the service to apply the change immediately. Using apply_immediately can result in a brief downtime as the server reboots."
  type        = bool
  default     = true
}

variable "final_snapshot" {
  description = "The name of your final snapshot when the replication group is deleted."
  type        = string
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00"
  type        = string
}

variable "notification_topic_arn" {
  description = "ARN of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my_sns_topic"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.notification_topic_arn == null,
      can(regex("^arn:aws:sns:\\w+(?:-\\w+)+:[[:digit:]]{12}:([a-zA-Z0-9-_]+)", var.notification_topic_arn))
    ])
    error_message = "SNS Topic ARN is required and allowed format of the SNS topic ARN is arn:aws:sns:<region>:<account-id>:<sns-topic-name>."
  }
}

variable "snapshot_window" {
  description = "Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. Example: 05:00-09:00"
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
  description = "One or more VPC security groups associated with the cache cluster"
  default     = null
}

variable "snapshot_arns" {
  type        = list(string)
  description = "Single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3."
  default     = null
}

variable "snapshot_name" {
  type        = string
  description = "Name of a snapshot from which to restore data into the new node group."
  default     = null
}

variable "snapshot_retention" {
  description = "Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. snapshot_retention_limit is not supported on cache.t1.micro cache nodes"
  type        = number
  default     = 15
  validation {
    condition = (
    var.snapshot_retention >= 15)
    error_message = "Error! Snapshot retention limit should be a minimum of 15 days as per SAF Rule."
  }
}

variable "subnet_group_description_redis" {
  description = " Description for the cache subnet group."
  type        = string
  default     = "Managed by Terraform"
}

variable "subnet_group_subnet_ids" {
  type        = list(string)
  description = "List of VPC Subnet IDs for the cache subnet group."
}

variable "parameters" {
  description = " A list of ElastiCache parameters to apply."
  type        = list(map(string))
  default     = []
}

variable "create_new_parametergroup" {
  description = "Whether to create a new parameter group or use existing parameter group."
  type        = bool
  default     = true
}

variable "existing_parameter_group_name" {
  description = "The name of the parameter group to associate with this cache cluster. valid: default.redis6.x"
  type        = string
  default     = null
}