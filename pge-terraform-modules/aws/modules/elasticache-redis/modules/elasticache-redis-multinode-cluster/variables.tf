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

# Variables for multinode-cluster 

variable "cluster_id" {
  description = "Replication group identifier. This parameter is stored as a lowercase string. Changing this value will re-create the resource."
  type        = string
}

variable "apply_immediately" {
  description = "Whether any database modifications are applied immediately, or during the next maintenance window.When you change an attribute, such as num_cache_nodes, by default it is applied in the next maintenance window. Because of this, Terraform may report a difference in its planning phase because the actual modification has not yet taken place. You can use the apply_immediately flag to instruct the service to apply the change immediately. Using apply_immediately can result in a brief downtime as the server reboots."
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "Password used to access a password protected server.The 'auth_token' has to be fetched from SSM Parameter store,which is a pre-requisite while using this module."
  type        = string
}

variable "data_tiering_enabled" {
  description = "Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type. This parameter must be set to true when using r6gd nodes."
  type        = bool
  default     = null
}

variable "redis_engine_version" {
  description = "Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine_version_actual."
  type        = string
}

variable "global_replication_group_id" {
  description = "The ID of the global replication group to which this replication group should belong. If this parameter is specified, the replication group is added to the specified global replication group as a secondary replication group; otherwise, the replication group is not part of any global replication group. If global_replication_group_id is set, the num_node_groups parameter (or the num_node_groups parameter of the deprecated cluster_mode block) cannot be set."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The ARN of the key that you wish to use if encrypting at rest."
  type        = string
  # default     = null
}

variable "multi_az_enabled" {
  description = "Specifies whether to enable Multi-AZ Support for the replication group. If true, automatic_failover_enabled must also be enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "preferred_cache_cluster_azs" {
  description = " List of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is considered. The first item in the list will be the primary node. Ignored when updating."
  type        = list(string)
  default     = null
}

variable "nodetype" {
  description = "Instance class to be used."
  type        = string
}

variable "notification_topic_arn" {
  description = "ARN of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my_sns_topic"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.notification_topic_arn == null,
      can(regex("^arn:aws:sns:\\w+(?:-\\w+)+:[[:digit:]]{12}:([a-zA-Z0-9])+(.*)$", var.notification_topic_arn))
    ])
    error_message = "Amazon SNS topic ARN is required and allowed format of the Amazon SNS topic ARN is arn:aws:sns:<region>:<account-id>:<sns-topic-name>."
  }
}

variable "port_number" {
  description = "The port number on which each of the cache nodes will accept connections. Redis the default port is 6379. "
  type        = number
  default     = 6379
}

variable "security_group_ids" {
  description = " One or more Amazon VPC security groups associated with this replication group. Use this parameter only when you are creating a replication group in an Amazon Virtual Private Cloud"
  type        = list(string)
  default     = []
}

variable "security_group_names" {
  description = "List of cache security group names to associate with this replication group."
  type        = list(string)
  default     = []
}

variable "final_snapshot" {
  description = "The name of your final snapshot when the replication group is deleted."
  type        = string
}

variable "snapshot_arns" {
  description = "List of ARNs that identify Redis RDB snapshot files stored in Amazon S3. The names object names cannot contain any commas."
  type        = list(string)
  default     = []
}

variable "snapshot_name" {
  description = " Name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
  type        = string
  default     = null
}

variable "snapshot_retention" {
  description = "Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted."
  type        = number
  default     = 15
  validation {
    condition = (
    var.snapshot_retention >= 15)
    error_message = "Error! Snapshot retention limit should be a minimum of 15 days as per SAF Rule."
  }
}

variable "snapshot_window" {
  description = "Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00"
  type        = string
  default     = null
}

variable "num_node_groups" {
  description = "Number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications. Required unless global_replication_group_id is set."
  type        = string
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications."
  type        = string
}

variable "timeouts_create" {
  description = "How long to wait for a replication group to be created."
  type        = string
  default     = "120m"
}

variable "timeouts_delete" {
  description = "How long to wait for a replication group to be deleted."
  type        = string
  default     = "80m"
}

variable "timeouts_update" {
  description = "How long to wait for replication group settings to be updated. This is also separately used for adding/removing replicas and online resize operation completion, if necessary."
  type        = string
  default     = "80m"
}

# Variables for aws_elasticache_parameter_group

variable "cluster_on_parameters" {
  description = " A list of ElastiCache parameters to apply."
  type        = list(map(string))
  default     = []
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

# Variables for aws_elasticache_subnet_group
variable "subnet_group_subnet_ids" {
  type        = list(string)
  description = "List of VPC Subnet IDs for the cache subnet group."
}

