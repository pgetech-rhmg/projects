variable "tags" {
  description = "A mapping of tags to assign resources for EFS"
  type        = map(string)
}

variable "task_name" {
  description = "Name of the DataSync Task."
  type        = string
  default     = null
}

variable "destination_location_arn" {
  description = "Amazon Resource Name (ARN) of destination location."
  type        = string
}

variable "source_location_arn" {
  description = "Amazon Resource Name (ARN) of source location."
  type        = string
}

# Task "options" block
variable "atime" {
  description = "A file metadata value that shows the time that the file was last accessed."
  type        = string
  default     = null
}

variable "bytes_per_second" {
  description = "A value that limits the bandwidth used by AWS DataSync."
  type        = number
  default     = null
}

variable "gid" {
  description = "The group ID of the file's owner."
  type        = string
  default     = null
}

variable "log_level" {
  description = "Determines the type of logs that DataSync publishes to a log stream in the Amazon CloudWatch log group that you provide. Valid values: OFF, BASIC, TRANSFER"
  type        = string
  default     = "TRANSFER"
}

variable "mtime" {
  description = "A value that indicates the last time that a file was modified before the sync. Valid values: NONE, PRESERVE."
  type        = string
  default     = null
}

variable "object_tags" {
  description = "Specifies whether object tags are maintained when transferring between object storage systems. If you want your DataSync task to ignore object tags, specify the NONE value. Valid values: PRESERVE, NONE."
  type        = string
  default     = null
}

variable "overwrite_mode" {
  description = "Determines whether files at the destination should be overwritten or preserved when copying files. Valid values: ALWAYS, NEVER."
  type        = string
  default     = null
}

variable "posix_permissions" {
  description = "Determines which users or groups can access a file for a specific purpose such as reading, writing, or execution of the file. Valid values: NONE, PRESERVE."
  type        = string
  default     = null
}

variable "preserve_deleted_files" {
  description = "Whether files deleted in the source should be removed or preserved in the destination file system. Valid values: PRESERVE, REMOVE."
  type        = string
  default     = null
}

variable "preserve_devices" {
  description = "Whether the DataSync Task should preserve the metadata of block and character devices in the source files system, and recreate the files with that device name and metadata on the destination. Valid values: NONE, PRESERVE"
  type        = string
  default     = null
}

variable "security_descriptor_copy_flags" {
  description = "Determines which components of the SMB security descriptor are copied from source to destination objects. This value is only used for transfers between SMB and Amazon FSx for Windows File Server locations, or between two Amazon FSx for Windows File Server locations. Valid values: NONE, OWNER_DACL, OWNER_DACL_SACL."
  type        = string
  default     = null
}

variable "task_queueing" {
  description = "Determines whether tasks should be queued before executing the tasks. Valid values: ENABLED, DISABLED."
  type        = string
  default     = null
}

variable "transfer_mode" {
  description = "Determines whether DataSync transfers only the data and metadata that differ between the source and the destination location, or whether DataSync transfers all the content from the source, without comparing to the destination location. Valid values: CHANGED, ALL."
  type        = string
  default     = null
}

variable "uid" {
  description = "User identifier of the file's owners. Valid values: BOTH, INT_VALUE, NAME, NONE"
  type        = string
  default     = null
}

variable "verify_mode" {
  description = "Whether a data integrity verification should be performed at the end of a task execution after all data and metadata have been transferred. Valid values: NONE, POINT_IN_TIME_CONSISTENT, ONLY_FILES_TRANSFERRED."
  type        = string
  default     = null
}

# Task "schedule" block
variable "schedule_expression" {
  description = "An expression that specifies when DataSync should start a scheduled task. See: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html."
  type        = string
  default     = null
}

# Task "excludes" block
variable "excludes" {
  description = "List of objects to exclude from the DataSync task"
  type        = list(object({ filter_type = string, value = string }))
  default     = []
}

# Task "includes" block
variable "includes" {
  description = "List of objects to include in the DataSync task"
  type        = list(object({ filter_type = string, value = string }))
  default     = []
}

# Task "task_report_config" block
variable "create_task_report" {
  description = "Whether to create a task report."
  type        = bool
  default     = false
}

variable "task_report_bucket_access_role_arn" {
  description = "The ARN of the role that grants AWS DataSync access to the Amazon S3 bucket."
  type        = string
  default     = null
}

variable "task_report_s3_bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the S3 bucket."
  type        = string
  default     = null
}

variable "task_report_subdirectory" {
  description = "The subdirectory in the S3 bucket to which to write the DataSync task report."
  type        = string
  default     = null
}

variable "task_report_s3_object_versioning" {
  description = "Specifies whether your task report includes the new version of each object transferred into an S3 bucket. This only applies if you enable versioning on your bucket. Keep in mind that setting this to INCLUDE can increase the duration of your task execution. Valid values: INCLUDE and NONE."
  type        = string
  default     = null
}

variable "task_report_output_type" {
  description = " Specifies the type of task report you'd like. Valid values: SUMMARY_ONLY and STANDARD."
  type        = string
  default     = null
}

variable "task_report_overrides" {
  description = "A list of objects that specify overrides for the DataSync task report."
  type        = bool
  default     = false
}

variable "task_report_deleted_override" {
  description = "Specifies the level of reporting for the files, objects, and directories that DataSync attempted to delete in your destination location. This only applies if you configure your task to delete data in the destination that isn't in the source. Valid values: ERRORS_ONLY and SUCCESSES_AND_ERRORS."
  type        = string
  default     = null
}

variable "task_report_skipped_override" {
  description = "Specifies the level of reporting for the files, objects, and directories that DataSync attempted to skip during your transfer. Valid values: ERRORS_ONLY and SUCCESSES_AND_ERRORS."
  type        = string
  default     = null
}

variable "task_report_transferred_override" {
  description = "Specifies the level of reporting for the files, objects, and directories that DataSync attempted to transfer. Valid values: ERRORS_ONLY and SUCCESSES_AND_ERRORS."
  type        = string
  default     = null
}

variable "task_report_verified_override" {
  description = "Specifies the level of reporting for the files, objects, and directories that DataSync attempted to verify at the end of your transfer. Valid values: ERRORS_ONLY and SUCCESSES_AND_ERRORS."
  type        = string
  default     = null
}

# Cloudwatch Log Group
variable "cloudwatch_log_group_name_prefix" {
  description = "Name prefix of the Cloudwatch log group"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_arn" {
  description = "Amazon Resource Name (ARN) of the CloudWatch Log group that is used to monitor and log events."
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting logs"
  type        = string
  default     = null
}
