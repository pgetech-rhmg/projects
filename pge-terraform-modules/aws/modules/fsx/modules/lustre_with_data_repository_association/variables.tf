#variables for lustre file system
variable "storage_capacity" {
  description = "The storage capacity (GiB) of the file system. Minimum of 1200."
  type        = number
  validation {
    condition     = var.storage_capacity >= 1200 && var.storage_capacity <= 65536
    error_message = "Error! The storage_capacity should be >=1200 & <=65536."
  }
}

variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from."
  type        = list(string)
  validation {
    condition = alltrue([
      for sub in var.subnet_ids : can(regex("^subnet-\\w+", sub))
    ])
    error_message = "Error! Valid subnet id is in the format 'subnet-xxxxxxx'."
  }
  validation {
    condition     = ("${length(var.subnet_ids)}" == 1)
    error_message = "Error! Only one subnet_id is allowed."
  }
}

variable "backup_id" {
  description = "The ID of the source backup to create the filesystem from."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces."
  type        = list(string)
  validation {
    condition     = alltrue([for sgi in var.security_group_ids : can(regex("^sg-\\w+", sgi))])
    error_message = "Error! Valid security_group_ids is in the format 'sg-xxxxxxxx'!."
  }
}

variable "weekly_maintenance_start_time" {
  description = "The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone."
  type        = string
  default     = null
  validation {
    condition     = (var.weekly_maintenance_start_time == null ? true : can(regex("[[:digit:]]{1}:[[:digit:]]{2}:[[:digit:]]{2}$", var.weekly_maintenance_start_time)))
    error_message = "Error! Enter a valid weekly_maintenance_start_time. weekly_maintenance_start_time should be in the format d:HH:MM."
  }
}

variable "kms_key_id" {
  description = "ARN for the KMS Key to encrypt the file system at rest."
  type        = string
  validation {
    condition     = var.kms_key_id == null ? true : can(regex("arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.kms_key_id))
    error_message = "Error! Enter a valid aws kms key id."
  }
}

variable "per_unit_storage_throughput" {
  description = "Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB. Valid values for PERSISTENT_2 deployment_type and SSD storage_type are 125, 250, 500, 1000."
  type        = number
  validation {
    condition = anytrue([
      var.per_unit_storage_throughput == 125,
      var.per_unit_storage_throughput == 250,
      var.per_unit_storage_throughput == 500,
    var.per_unit_storage_throughput == 1000])
    error_message = "Error! Valid values for PERSISTENT_2 deployment_type and SSD storage_type are 125, 250, 500, 1000."
  }
}

variable "copy_tags_to_backups" {
  description = "A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false."
  type        = bool
  default     = false
}

variable "data_compression_type" {
  description = "Sets the data compression configuration for the file system. Valid values are LZ4 and NONE. Default value is NONE."
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["LZ4", "NONE"], var.data_compression_type)
    error_message = "Error! enter a valid value for data_compression_type. Valid values are LZ4 & NONE."
  }
}

variable "file_system_type_version" {
  description = "Sets the Lustre version for the file system that you're creating.Valid values for 2.12 include all deployment types."
  type        = string
  default     = "2.12"
  validation {
    condition = anytrue([
      var.file_system_type_version == "2.10",
    var.file_system_type_version == "2.12"])
    error_message = "Error! file_system_type_version value should be either 2.10 or 2.12."
  }
}

variable "lustre_log_configuration_destination" {
  description = " The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix. If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group."
  type        = string
  default     = null
  validation {
    condition     = (var.lustre_log_configuration_destination == null ? true : can(regex("arn:aws:logs:\\w+(?:-\\w+)+:[[:digit:]]{12}:log-group:/aws/fsx/([a-zA-Z0-9])+(.*)$", var.lustre_log_configuration_destination)))
    error_message = "Error! enter a valid arn for lustre_log_configuration_destination."
  }
}

variable "lustre_log_configuration_level" {
  description = "Sets which data repository events are logged by Amazon FSx. Valid values are WARN_ONLY, FAILURE_ONLY, ERROR_ONLY, WARN_ERROR and DISABLED."
  type        = string
  default     = "DISABLED"
  validation {
    condition     = contains(["WARN_ONLY", "ERROR_ONLY", "WARN_ERROR", "DISABLED"], var.lustre_log_configuration_level)
    error_message = "Error! enter valid values for lustre_log_configuration_level. valid values are WARN_ONLY, ERROR_ONLY, WARN_ERROR & DISABLED."
  }
}

variable "lustre_timeouts" {
  description = "Provide the timeouts configurations for lustre file system."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for ki, vi in var.lustre_timeouts : can(regex("^[[:digit:]]+m$", vi))])
    error_message = "Error! enter valid inputs for timeout configurations. The input value for timeout configurations should end with m. (eg : 20m)."
  }

  validation {
    condition     = alltrue([for ki, vi in var.lustre_timeouts : contains(["create", "update", "delete"], ki)])
    error_message = "Error! The valid timeouts configurations are create, update & delete."
  }
}

#variables for data repository association
variable "batch_import_meta_data_on_create" {
  description = "Set to true to run an import data repository task to import metadata from the data repository to the file system after the data repository association is created."
  type        = bool
  default     = false
}

variable "data_repository_path" {
  description = "The path to the Amazon S3 data repository that will be linked to the file system."
  type        = string
  validation {
    condition     = (can(regex("^s3://\\w+", var.data_repository_path)))
    error_message = "Error! enter a valid data_repository_path."
  }
}

variable "file_system_path" {
  description = "A path on the file system that points to a high-level directory (such as /ns1/) or subdirectory (such as /ns1/subdir/) that will be mapped 1-1 with data_repository_path."
  type        = string
  validation {
    condition     = (can(regex("^/\\w+", var.file_system_path)))
    error_message = "Error! enter a valid file_system_path. Valid file_system_path should begins with a forward slash."
  }
}

variable "imported_file_chunk_size" {
  description = "For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk."
  type        = number
  default     = null
  validation {
    condition     = (var.imported_file_chunk_size == null ? true : (var.imported_file_chunk_size >= 1 && var.imported_file_chunk_size <= 512000))
    error_message = "Error! The value for imported_file_chunk_size must be between 1 and 512000."
  }
}

variable "delete_data_in_filesystem" {
  description = "Set to true to delete files from the file system upon deleting this data repository association."
  type        = bool
  default     = false
}

variable "auto_export_policy_events" {
  description = "A list of file event types to automatically export to your linked S3 bucket. Valid values are NEW, CHANGED, DELETED."
  type        = list(string)
  default     = null
  validation {
    condition = (var.auto_export_policy_events == null ? true : (alltrue([
    for epe in var.auto_export_policy_events : contains(["NEW", "CHANGED", "DELETED"], epe)])))
    error_message = "Error! enter valid values for auto_export_policy_events. valid values are NEW, CHANGED & DELETED."
  }
  validation {
    condition = (var.auto_export_policy_events == null ? true : (
    "${length(var.auto_export_policy_events)}" <= 3))
    error_message = "Error! Only a maximum of 3 values can be given for auto_export_policy_events."
  }
}

variable "auto_import_policy_events" {
  description = "A list of file event types automatically import from the linked S3 bucket. Valid values are NEW, CHANGED, DELETED. Max of 3."
  type        = list(string)
  default     = null
  validation {
    condition = (var.auto_import_policy_events == null ? true : (alltrue([
    for ipe in var.auto_import_policy_events : contains(["NEW", "CHANGED", "DELETED"], ipe)])))
    error_message = "Error! enter valid values for auto_import_policy_events. valid values are NEW, CHANGED & DELETED."
  }
  validation {
    condition = (var.auto_import_policy_events == null ? true : (
    "${length(var.auto_import_policy_events)}" <= 3))
    error_message = "Error! Only a maximum of 3 values can be given for auto_import_policy_events."
  }
}

variable "data_repository_association_timeouts" {
  description = "Provide the timeouts configurations for data_repository_association."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for ki, vi in var.data_repository_association_timeouts : can(regex("^[[:digit:]]+m$", vi))])
    error_message = "Error! enter valid inputs for timeout configurations. The input value for timeout configurations should end with m. (eg : 20m)."
  }

  validation {
    condition     = alltrue([for ki, vi in var.data_repository_association_timeouts : contains(["create", "update", "delete"], ki)])
    error_message = "Error! The valid timeouts configurations are create, update & delete."
  }
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