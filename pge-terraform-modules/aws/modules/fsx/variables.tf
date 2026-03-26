variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment_type to MULTI_AZ_1."
  type        = list(string)
  validation {
    condition = alltrue([
      for sub in var.subnet_ids : can(regex("^subnet-\\w+", sub))
    ])
    error_message = "Error! Valid subnet id is in the format 'subnet-xxxxxxx'."
  }
}

variable "backup_id" {
  description = "The ID of the source backup to create the filesystem from."
  type        = string
  default     = null
}

variable "automatic_backup_retention_days" {
  description = "The number of days to retain automatic backups. Minimum of 0 and maximum of 35. Defaults to 7. Set to 0 to disable."
  type        = number
  default     = 15
  validation {
    condition = (
      var.automatic_backup_retention_days >= 15 &&
    var.automatic_backup_retention_days <= 90)
    error_message = "Error! automatic_backup_retention_days value should be between 15 second to  90."
  }
}

variable "copy_tags_to_backups" {
  description = "A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false."
  type        = bool
  default     = false
}

variable "daily_automatic_backup_start_time" {
  description = "The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN for the KMS Key to encrypt the file system at rest. Defaults to an AWS managed KMS Key."
  type        = string
  validation {
    condition     = var.kms_key_id == null ? true : can(regex("arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.kms_key_id))
    error_message = "Error! Enter a valid aws kms key id."
  }
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces."
  type        = list(string)
  validation {
    condition     = alltrue([for sgi in var.security_group_ids : can(regex("^sg-\\w+", sgi))])
    error_message = "Error! Provide list of security_group_ids, value should be in form of 'sg-xxxxxxxx'!."
  }
}

variable "weekly_maintenance_start_time" {
  description = "The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone."
  type        = string
  default     = null
}

variable "timeouts" {
  description = "provides the following Timeouts configuration options: create, update, delete."
  type        = map(string)
  default     = {}
}

variable "file_system" {
  description = <<-DOC
    file_system_type:
       The type of file system.Valid values are windows & lustre.
    storage_capacity:
      Storage capacity (GiB) of the file system.
    deployment_type:
      Specifies the file system deployment type.
    windows_throughput_capacity:
      Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048.
    windows_preferred_subnet_id:
      Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI_AZ_1.
    windows_shared_active_directory_id:
      The ID for an existing Microsoft Active Directory instance that the file system should join when it's created. 
    storage_type:
       Specifies the storage type, Valid values are SSD and HDD
    lustre_per_unit_storage_throughput:
       Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB, required for the PERSISTENT_1 and PERSISTENT_2 deployment_type. Valid values for PERSISTENT_1 deployment_type and SSD storage_type are 50, 100, 200. Valid values for PERSISTENT_1 deployment_type and HDD storage_type are 12, 40. Valid values for PERSISTENT_2 deployment_type and SSD storage_type are 125, 250, 500, 1000.
    lustre_drive_cache_type:
       The type of drive cache used by PERSISTENT_1 filesystems that are provisioned with HDD storage_type. Required for HDD storage_type, set to either READ or NONE.           
    windows_aliases
       An array DNS alias names that you want to associate with the Amazon FSx file system.
    windows_skip_final_backup
       When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false.
    lustre_auto_import_policy
       How Amazon FSx keeps your file and directory listings up to date as you add or modify objects in your linked S3 bucket.
    lustre_data_compression_type
       Sets the data compression configuration for the file system. Valid values are LZ4 and NONE. Default value is NONE.
    lustre_file_system_type_version
       Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH_1, SCRATCH_2 and PERSISTENT_1 deployment types. Valid values for 2.12 include all deployment types.
    lustre_export_path
       S3 URI (with optional prefix) where the root of your Amazon FSx file system is exported.
    lustre_import_path   
       S3 URI (with optional prefix) that you're using as the data repository for your FSx for Lustre file system.
    lustre_imported_file_chunk_size   
       For files imported from a data repository, this value determines the stripe count and maximum amount of data per file (in MiB) stored on a single physical disk. Can only be specified with import_path argument. Defaults to 1024.
    lustre_log_configuration_destination
       The Amazon Resource Name (ARN) that specifies the destination of the logs. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix. If you do not provide a destination, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/lustre log group.
    lustre_log_configuration_level
       Sets which data repository events are logged by Amazon FSx. Valid values are WARN_ONLY, FAILURE_ONLY, ERROR_ONLY, WARN_ERROR and DISABLED.
    windows_audit_log_destination
      The Amazon Resource Name (ARN) for the destination of the audit logs. The destination can be any Amazon CloudWatch Logs log group ARN or Amazon Kinesis Data Firehose delivery stream ARN.
    windows_file_access_audit_log_level
      Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED. Default value is DISABLED.
    windows_file_share_access_audit_log_level
      Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED. Default value is DISABLED.
  DOC

  type = object({
    file_system_type                          = string
    storage_capacity                          = number
    deployment_type                           = string
    windows_throughput_capacity               = number
    windows_preferred_subnet_id               = string
    windows_shared_active_directory_id        = string
    storage_type                              = string
    lustre_per_unit_storage_throughput        = number
    lustre_drive_cache_type                   = string
    windows_aliases                           = list(string)
    windows_skip_final_backup                 = bool
    lustre_auto_import_policy                 = string
    lustre_data_compression_type              = string
    lustre_file_system_type_version           = string
    lustre_export_path                        = string
    lustre_import_path                        = string
    lustre_imported_file_chunk_size           = number
    lustre_log_configuration_destination      = string
    lustre_log_configuration_level            = string
    windows_audit_log_destination             = string
    windows_file_access_audit_log_level       = string
    windows_file_share_access_audit_log_level = string
  })

  validation {
    condition     = (var.file_system.windows_audit_log_destination == null ? true : can(regex("arn:aws:logs:\\w+(?:-\\w+)+:[[:digit:]]{12}:log-group:/aws/fsx/([a-zA-Z0-9])+(.*)$", var.file_system.windows_audit_log_destination)))
    error_message = "Error! enter a valid arn for windows_audit_log_destination."
  }

  validation {
    condition = anytrue([
      var.file_system.windows_file_access_audit_log_level == null,
      var.file_system.windows_file_access_audit_log_level == "SUCCESS_ONLY",
      var.file_system.windows_file_access_audit_log_level == "FAILURE_ONLY",
      var.file_system.windows_file_access_audit_log_level == "SUCCESS_AND_FAILURE",
    var.file_system.windows_file_access_audit_log_level == "DISABLED"])
    error_message = "Error! enter valid values for windows_file_access_audit_log_level. valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE & DISABLED."
  }

  validation {
    condition = anytrue([
      var.file_system.windows_file_share_access_audit_log_level == null,
      var.file_system.windows_file_share_access_audit_log_level == "SUCCESS_ONLY",
      var.file_system.windows_file_share_access_audit_log_level == "FAILURE_ONLY",
      var.file_system.windows_file_share_access_audit_log_level == "SUCCESS_AND_FAILURE",
    var.file_system.windows_file_share_access_audit_log_level == "DISABLED"])
    error_message = "Error! enter valid values for windows_file_share_access_audit_log_level. valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE & DISABLED."
  }

  validation {
    condition     = var.file_system.windows_audit_log_destination != null && var.file_system.windows_file_access_audit_log_level == null || var.file_system.windows_audit_log_destination != null && var.file_system.windows_file_share_access_audit_log_level == null || var.file_system.windows_audit_log_destination != null && var.file_system.windows_file_share_access_audit_log_level == null && var.file_system.windows_file_access_audit_log_level == null ? false : true
    error_message = "Error! windows_file_access_audit_log_level or windows_file_share_access_audit_log_level is required while passing windows_audit_log_destination."
  }

  validation {
    condition     = var.file_system.file_system_type == "lustre" && var.file_system.windows_file_share_access_audit_log_level != null || var.file_system.file_system_type == "lustre" && var.file_system.windows_file_access_audit_log_level != null || var.file_system.file_system_type == "lustre" && var.file_system.windows_file_access_audit_log_level != null && var.file_system.windows_file_share_access_audit_log_level != null ? false : true
    error_message = "Error! windows_audit_log_destination, windows_file_access_audit_log_level & windows_file_share_access_audit_log_level is not supported in lustre file system."
  }

  validation {
    condition     = (var.file_system.lustre_log_configuration_destination == null ? true : can(regex("arn:aws:logs:\\w+(?:-\\w+)+:[[:digit:]]{12}:log-group:/aws/fsx/([a-zA-Z0-9])+(.*)$", var.file_system.lustre_log_configuration_destination)))
    error_message = "Error! enter a valid arn for lustre_log_configuration_destination."
  }

  validation {
    condition     = var.file_system.lustre_log_configuration_destination != null && var.file_system.lustre_log_configuration_level == null ? false : true
    error_message = "Error! lustre_log_configuration_level is required while passing lustre_log_configuration_destination."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_log_configuration_level != null || var.file_system.file_system_type == "windows" && var.file_system.lustre_log_configuration_level != null && var.file_system.lustre_log_configuration_destination != null ? false : true
    error_message = "Error! lustre_log_configuration_destination & lustre_log_configuration_level is not supported in windows file system."
  }

  validation {
    condition = anytrue([
      var.file_system.lustre_log_configuration_level == null,
      var.file_system.lustre_log_configuration_level == "WARN_ONLY",
      var.file_system.lustre_log_configuration_level == "ERROR_ONLY",
      var.file_system.lustre_log_configuration_level == "WARN_ERROR",
    var.file_system.lustre_log_configuration_level == "DISABLED"])
    error_message = "Error! enter valid values for lustre_log_configuration_level. valid values are WARN_ONLY, ERROR_ONLY, WARN_ERROR & DISABLED."
  }

  validation {
    condition     = var.file_system.deployment_type == "SCRATCH_1" && var.file_system.lustre_export_path != null || var.file_system.deployment_type == "SCRATCH_2" && var.file_system.lustre_export_path != null || var.file_system.deployment_type == "PERSISTENT_2" && var.file_system.lustre_export_path != null ? false : true
    error_message = "Error! lustre_export_path is only supported on PERSISTENT_1 deployment types."
  }

  validation {
    condition     = var.file_system.deployment_type == "SCRATCH_1" && var.file_system.lustre_import_path != null || var.file_system.deployment_type == "SCRATCH_2" && var.file_system.lustre_import_path != null || var.file_system.deployment_type == "PERSISTENT_2" && var.file_system.lustre_import_path != null ? false : true
    error_message = "Error! lustre_import_path is only supported on PERSISTENT_1 deployment types."
  }

  validation {
    condition     = var.file_system.deployment_type == "SCRATCH_1" && var.file_system.lustre_imported_file_chunk_size != null || var.file_system.deployment_type == "SCRATCH_2" && var.file_system.lustre_imported_file_chunk_size != null || var.file_system.deployment_type == "PERSISTENT_2" && var.file_system.lustre_imported_file_chunk_size != null ? false : true
    error_message = "Error! lustre_imported_file_chunk_size is only supported on PERSISTENT_1 deployment types."
  }

  validation {
    condition     = var.file_system.lustre_import_path == null && var.file_system.lustre_export_path != null || var.file_system.lustre_import_path == null && var.file_system.lustre_imported_file_chunk_size != null || var.file_system.lustre_import_path == null && var.file_system.lustre_imported_file_chunk_size != null && var.file_system.lustre_export_path != null ? false : true
    error_message = "Error! lustre_export_path &  lustre_imported_file_chunk_size can only be specified with lustre_import_path."
  }

  validation {
    condition     = (var.file_system.lustre_imported_file_chunk_size == null ? true : (var.file_system.lustre_imported_file_chunk_size >= 1 && var.file_system.lustre_imported_file_chunk_size <= 512000))
    error_message = "Error! The value for lustre_imported_file_chunk_size must be between 1 and 512000."
  }

  validation {
    condition = (var.file_system.lustre_file_system_type_version == null ? true : anytrue([
      var.file_system.lustre_file_system_type_version == "2.10",
    var.file_system.lustre_file_system_type_version == "2.12"]))
    error_message = "Error! lustre_file_system_type_version value should be either 2.10 or 2.12."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_export_path != null ? false : true
    error_message = "Error! lustre_export_path is not supported in windows file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_import_path != null ? false : true
    error_message = "Error! lustre_import_path is not supported in windows file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_imported_file_chunk_size != null ? false : true
    error_message = "Error! lustre_imported_file_chunk_size is not supported in windows file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_file_system_type_version == "2.10" || var.file_system.file_system_type == "windows" && var.file_system.lustre_file_system_type_version == "2.12" ? false : true
    error_message = "Error! lustre_file_system_type_version is not supported in windows file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_auto_import_policy != null ? false : true
    error_message = "Error! lustre_auto_import_policy is not supported in windows file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "lustre" && var.file_system.windows_aliases != null ? false : true
    error_message = "Error! windows_aliases is not supported in lustre file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "lustre" && var.file_system.windows_skip_final_backup == true || var.file_system.file_system_type == "lustre" && var.file_system.windows_skip_final_backup == false ? false : true
    error_message = "Error! windows_skip_final_backup is not supported in lustre file system."
  }

  validation {
    condition     = (var.file_system.lustre_file_system_type_version == null ? true : contains(["LZ4", "NONE"], var.file_system.lustre_data_compression_type))
    error_message = "Error! enter a valid value for lustre_data_compression_type. Valid values are LZ4 & NONE."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.lustre_data_compression_type == "NONE" || var.file_system.file_system_type == "windows" && var.file_system.lustre_data_compression_type == "LZ4" ? false : true
    error_message = "Error! lustre_data_compression_type is not supported in windows file system."
  }

  validation {
    condition     = contains(["windows", "lustre"], var.file_system.file_system_type)
    error_message = "Error! enter a valid value for file_system. Valid values are Windows & lustre."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" ? var.file_system.storage_capacity >= 32 && var.file_system.storage_capacity <= 65536 : var.file_system.storage_capacity >= 1200
    error_message = "Error! The storage_capacity should be >=32 & <=65536 for windows file system and the value should be >=1200 if using the lustre file system."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" ? contains(["MULTI_AZ_1", "SINGLE_AZ_2", "SINGLE_AZ_1"], var.file_system.deployment_type) : contains(["SCRATCH_1", "SCRATCH_2", "PERSISTENT_1", "PERSISTENT_2"], var.file_system.deployment_type)
    error_message = "Error! enter a valid value for deployment_type.The valid values for windows file system are MULTI_AZ_1, SINGLE_AZ_2 & SINGLE_AZ_1 and the valid values for luster file system are SCRATCH_1, SCRATCH_2, PERSISTENT_1 & PERSISTENT_2."
  }

  validation {
    condition     = contains(["HDD", "SSD"], var.file_system.storage_type)
    error_message = "Error! Invalid value for storage_type. Valid values are HDD & SSD."
  }

  validation {
    condition = (var.file_system.windows_throughput_capacity == null ? true : (
      var.file_system.windows_throughput_capacity >= 8 &&
    var.file_system.windows_throughput_capacity <= 2048))
    error_message = "Error! windows_throughput_capacity value should be between 8 second to  2048."
  }

  validation {
    condition     = var.file_system.windows_preferred_subnet_id == null && var.file_system.file_system_type == "windows" && var.file_system.deployment_type == "MULTI_AZ_1" ? false : true
    error_message = "Error! windows_preferred_subnet_id is required when deployment type is MULTI_AZ_1."
  }

  validation {
    condition     = var.file_system.windows_throughput_capacity == null && var.file_system.file_system_type == "windows" ? false : true
    error_message = "Error! windows_throughput_capacity is required in windows file system."
  }

  validation {
    condition     = (var.file_system.windows_preferred_subnet_id == null ? true : can(regex("^subnet-\\w+", var.file_system.windows_preferred_subnet_id)))
    error_message = "Error! Valid windows_preferred_subnet_id is in the format 'subnet-xxxxxxx'."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.windows_shared_active_directory_id == null ? false : true
    error_message = "Error! windows_shared_active_directory_id is required in windows file system."
  }

  validation {
    condition     = var.file_system.deployment_type == "PERSISTENT_1" && var.file_system.lustre_per_unit_storage_throughput == null || var.file_system.deployment_type == "PERSISTENT_2" && var.file_system.lustre_per_unit_storage_throughput == null ? false : true
    error_message = "Error! lustre_per_unit_storage_throughput is required for the PERSISTENT_1 and PERSISTENT_2 deployment_type."
  }

  validation {
    condition = (var.file_system.lustre_per_unit_storage_throughput == null ? true : anytrue([
      var.file_system.lustre_per_unit_storage_throughput == 50,
      var.file_system.lustre_per_unit_storage_throughput == 100,
      var.file_system.lustre_per_unit_storage_throughput == 200,
      var.file_system.lustre_per_unit_storage_throughput == 12,
      var.file_system.lustre_per_unit_storage_throughput == 40,
      var.file_system.lustre_per_unit_storage_throughput == 125,
      var.file_system.lustre_per_unit_storage_throughput == 250,
      var.file_system.lustre_per_unit_storage_throughput == 500,
    var.file_system.lustre_per_unit_storage_throughput == 1000]))
    error_message = "Error! Valid values for PERSISTENT_1 deployment_type and SSD storage_type are 50, 100, 200. Valid values for PERSISTENT_1 deployment_type and HDD storage_type are 12, 40. Valid values for PERSISTENT_2 deployment_type and SSD storage_type are 125, 250, 500, 1000."
  }

  validation {
    condition     = (var.file_system.lustre_drive_cache_type == null ? true : contains(["READ", "NONE"], var.file_system.lustre_drive_cache_type))
    error_message = "Error! enter a valid value for lustre_drive_cache_type. Valid values are READ & NONE."
  }

  validation {
    condition     = var.file_system.storage_type == "HDD" && var.file_system.deployment_type == "PERSISTENT_1" && var.file_system.lustre_drive_cache_type == null ? false : true
    error_message = "Error! lustre_drive_cache_type is required when storage_type is HDD & deployment_type is PERSISTENT_1 in lustre file system."
  }

  validation {
    condition     = var.file_system.storage_type == "HDD" && var.file_system.deployment_type == "PERSISTENT_2" || var.file_system.storage_type == "HDD" && var.file_system.deployment_type == "SCRATCH_1" || var.file_system.storage_type == "HDD" && var.file_system.deployment_type == "SCRATCH_2" ? false : true
    error_message = "Error! HDD is only supported on PERSISTENT_1 deployment types."
  }

  validation {
    condition     = var.file_system.storage_type == "HDD" && var.file_system.deployment_type == "SINGLE_AZ_1" ? false : true
    error_message = "Error! HDD is supported on SINGLE_AZ_2 and MULTI_AZ_1 Windows file system deployment types."
  }

  validation {
    condition     = var.file_system.file_system_type == "windows" && var.file_system.storage_type == "HDD" && var.file_system.storage_capacity < 2000 ? false : true
    error_message = "Error! If the storage type is set to HDD the minimum value is 2000."
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