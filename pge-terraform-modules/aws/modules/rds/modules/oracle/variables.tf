
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "password" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
  default     = null
  validation {
    condition     = var.password == null ? true : length(var.password) >= 16
    error_message = "Must be at least 16 characters in length."
  }
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

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not."
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" { #pAutoMinorUpgrade
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN."
  type        = string
  default     = null
}


variable "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate."
  type        = string
  default     = null
}


variable "license_model" {
  description = "License model information for this DB instance. Optional, but required for some DB engines, i.e. Oracle SE1"
  type        = string
  default     = null
}

variable "engine" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) The database engine to use. For supported values, see the Engine parameter in API action CreateDBInstance. Cannot be specified for a replica. Note that for Amazon Aurora instances the engine must match the DB cluster's engine'. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide."
  type        = string
  validation {
    condition     = contains(["oracle-ee", "oracle-ee-cdb", "oracle-se2", "oracle-se2-cdb"], var.engine)
    error_message = "Valid values for engine are oracle-ee,oracle-ee-cdb,oracle-se2,oracle-se2-cdb"
  }
}


variable "engine_version" {
  description = "The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the attribute engine_version_actual.  Note that for Amazon Aurora instances the engine version must match the DB cluster's engine version'. Cannot be specified for a replica."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip_final_snapshot is set to false. The value must begin with a letter, only contain alphanumeric characters and hyphens, and not end with a hyphen or contain two consecutive hyphens. Must not be provided when deleting a read replica."
  type        = string
  default     = null
}

variable "final_snapshot_identifier_prefix" {
  description = "The name which is prefixed to the final snapshot on cluster destroy"
  type        = string
  default     = "final"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The DB name to create. If omitted, no database is created initially.  The Oracle System ID (SID) of the created DB instance. If you specify null, the default value ORCL is used. You can't specify the string NULL, or any other reserved word, for DBName.  Can't be longer than 8 characters"
  type        = string
  default     = "ORCL"
  validation {
    condition     = var.db_name == upper(substr(var.db_name, 0, 8))
    error_message = "DB Name must be upper case and no longer than 8 characters."
  }
}
variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}
variable "nchar_character_set_name" {
  description = "(Optional, Forces new resource) The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS."
  type        = string
  default     = null
}

variable "replica_mode" {
  description = "(Optional) Specifies whether the replica is in either mounted or open-read-only mode. This attribute is only supported by Oracle instances. Oracle replicas operate in open-read-only mode unless otherwise specified. See Working with Oracle Read Replicas for more information."
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
  default     = 0
}

variable "storage_throughput" {
  description = "(Optional) The storage throughput value for the DB instance. Can only be set when storage_type is 'gp3'. Cannot be specified if the allocated_storage value is below a per-engine threshold. See the RDS User Guide for details."
  type        = number
  default     = null
}

# Set to false for SAF compliance
variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
  validation {
    condition     = var.publicly_accessible == false
    error_message = "Must be false."
  }
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in"
  type        = string
}

variable "domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service"
  type        = string
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  type        = string
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 1
  validation {
    condition     = var.monitoring_interval > 0
    error_message = "Monitoring interval must be greater than 0."
  }
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 15
  validation {
    condition     = var.backup_retention_period >= 15
    error_message = "Must be at least 15 days."
  }
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Restore to a point in time. This setting does not apply to aurora-mysql or aurora-postgresql."
  type        = map(string)
  default     = null
}

variable "s3_import" {
  description = "Restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
}

variable "db_instance_tags" {
  description = "Additional tags for the DB instance"
  type        = map(string)
  default     = {}
}

variable "db_option_group_tags" {
  description = "Additional tags for the DB option group"
  type        = map(string)
  default     = {}
}

variable "db_parameter_group_tags" {
  description = "Additional tags for the  DB parameter group"
  type        = map(string)
  default     = {}
}

variable "db_subnet_group_tags" {
  description = "Additional tags for the DB subnet group"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)

}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default = [
    {
      name  = "audit_trail",
      value = "DB"
    },
    {
      name  = "open_cursors",
      value = "5000"
    }

  ]
}

variable "options" {
  description = "A list of DB options to apply with an option group. Depends on DB engine"
  type = list(object({
    db_security_group_memberships  = list(string)
    option_name                    = string
    port                           = number
    version                        = string
    vpc_security_group_memberships = list(string)

    option_settings = list(object({
      name  = string
      value = string
    }))
  }))

  default = []

}

variable "character_set_name" {
  description = "(Optional) The character set name to use for DB encoding in Oracle instances. This can't be changed. See Oracle Character Sets Supported in Amazon RDS and Collations and Character Sets for Microsoft SQL Server for more information. This can only be set on creation."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values for Oracle: trace, audit, alert, listener"
  type        = list(string)
  default     = ["trace", "audit", "alert", "listener"]
}

variable "timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times"
  type        = map(string)
  default = {
    create = "60m"
    update = "80m"
    delete = "60m"
  }
}

variable "option_group_timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type        = map(string)
  default = {
    delete = "35m"
  }
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "max_allocated_storage" { #pStorageMaxGB
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated_storage. Must be greater than or equal to allocated_storage or 0 to disable Storage Autoscaling."
  type        = number
  default     = 0
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = true
}

variable "random_password_length" {
  description = "(Optional) Length of random password to create. (default: 16)"
  type        = number
  default     = 16
  validation {
    condition     = var.random_password_length >= 16
    error_message = "Must be at least 16 characters in length."
  }
}
/****************************************Secrets Manager***********************************************/

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 7
}

variable "secretsmanager_tags" {
  description = "Key-value map of user-defined tags that are attached to the secret"
  type        = map(string)
  default     = {}
}

/*********************************Security Group*******************************************************/


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

/*********************************Security Group*******************************************************/

# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}

variable "s3_bucket_arn" {
  description = "Existing S3 bucket name for RDS export/import"
  type        = string
  default     = ""
}

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
  description = "Alarm threshold for the 'highDiskQueueDepth' alarm"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted.  Note that if you are creating a cross-region read replica this field is ignored and you should instead declare kms_key_id with a valid ARN. The default is false if not specified."
  type        = bool
  default     = true
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

variable "create_low_disk_burst_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the low disk burst alarm.  Default is to create it (for backwards compatible support)"
}

variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
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

variable "rotation_enabled" {
  description = "Specifies if rotation is set or not"
  type        = bool
  default     = false
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
  default     = true
  validation {
    condition     = var.secret_version_enabled == true
    error_message = "Must be true as per SAF compliance."
  }
}

variable "rotation_after_days" {
  description = "A structure that defines the rotation configuration for this secret"
  type        = number
  default     = 89
  validation {
    condition     = var.rotation_after_days < 90
    error_message = "Must be less than 90 as per SAF compliance."
  }
}

# rotation lambda variables, necessary for SAF compliance
variable "lambda_function_name" {
  type        = string
  description = "Name of lambda function used for the secret rotation."
  default     = "secretsmanager_rotation"

}

variable "lambda_description" {
  type        = string
  description = "Description of lambda used for the secret rotation"
  default     = "Lambda function code for secretsmanager rotation"
}

variable "lambda_handler_name" {
  type        = string
  description = "Lambda function entrypoint in your code"
  default     = null
}
variable "lambda_runtime" {
  type        = string
  description = "Identifier of the lambda function's runtime"
  default     = "python3.9"
  validation {
    condition     = contains(["nodejs14.x", "nodejs12.x", "nodejs10.x", "python3.9", "python3.8", "python3.7", "ruby2.7", "java11", "java8.al2", "java8", "go1.x", "dotnet6", "dotnetcore3.1", "dotnetcore2.1", "provided.al2", "provided"], var.lambda_runtime)
    error_message = "Error! enter a valid value for runtime.Valid values are nodejs14.x, nodejs12.x, nodejs10.x, python3.9, python3.8, ruby2.7, java11, java8.al2, java8, go1.x, dotnet6, dotnetcore3.1, dotnetcore2.1, provided.al2, provided."
  }
}

variable "sm_rotation_policy" {
  type        = string
  default     = null
  description = "Valid JSON document representing a resource policy for the rotation lambda function"
  validation {
    condition     = var.sm_rotation_policy == null ? true : can(jsondecode(var.sm_rotation_policy))
    error_message = "Error! Invalid JSON for custom policy. Provide a valid JSON for secrets manager."
  }
}

variable "environment_variables" {
  description = <<-DOC
    variables:
       Map of environment variables that are accessible from the function code during execution.
    kms_key_arn:
      Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables.The kms key is mandatory when we set the environment variables.
  DOC
  type = object({
    variables   = map(string)
    kms_key_arn = string
  })
  default = {
    variables   = null
    kms_key_arn = null
  }
  #If the argument variables is not empty then the validation will check whether the kms is valid or not.
  #If the kms_key_arn is invalid, It will give the validation error.
  validation {
    condition     = var.environment_variables.variables == null ? true : can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.environment_variables.kms_key_arn))
    error_message = "Error! enter a valid Kms key Arn."
  }
}


variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 10
  validation {
    condition = (
      var.timeout >= 1 &&
    var.timeout <= 300)
    error_message = "Lambda function timeout value should be between 1 second to  300 seconds."
  }
}

# Lambda Layer version s3 variables
variable "layer_version_compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified"
  type        = list(string)
  default     = ["python3.9"]
}

variable "layer_version_layer_name" {
  description = "Unique name for your Lambda Layer"
  type        = string
  default     = null
}

variable "layer_version_permission_principal" {
  description = "AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. This bucket must reside in the same AWS region where you are creating the Lambda function"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri."
  type        = string
  default     = null
}

variable "layer_version_permission_statement_id" {
  description = "The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for"
  type        = string
  default     = null
}

variable "layer_version_compatible_architectures" {
  description = "List of Architectures this layer is compatible with. Currently x86_64 and arm64 can be specified"
  type        = string
  default     = null
}

variable "layer_version_permission_action" {
  description = "Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documentation."
  type        = string
  default     = null
}

variable "source_dir" {
  description = "Package entire contents of this directory into the archive."
  type        = string
  default     = null
}

variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
  default     = null
}