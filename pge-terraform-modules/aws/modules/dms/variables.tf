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

# Variables for dms replication task

variable "migration_type" {
  description = "The migration type. Can be one of full-load | cdc | full-load-and-cdc."
  type        = string
  validation {
    condition = anytrue([
      var.migration_type == "full-load",
      var.migration_type == "cdc",
      var.migration_type == "full-load-and-cdc"
    ])
    error_message = "Error! Values for dms migration_type should be one of full-load | cdc | full-load-and-cdc."
  }
}

variable "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance."
  type        = string
}

variable "replication_task_id" {
  description = "The replication task identifier.Must contain from 1 to 255 alphanumeric characters or hyphens.First character must be a letter.Cannot end with a hyphen.Cannot contain two consecutive hyphens."
  type        = string
}

variable "source_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) string that uniquely identifies the source endpoint."
  type        = string
}

variable "table_mappings" {
  description = "An escaped JSON string that contains the table mappings. For information on table mapping see Using Table Mapping with an AWS Database Migration Service Task to Select and Filter Data."
  type        = string
  validation {
    condition     = can(jsondecode(var.table_mappings))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON."
  }
}

variable "target_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) string that uniquely identifies the target endpoint."
  type        = string
}

# Optional Variables

variable "cdc_start_position" {
  description = "Indicates when you want a change data capture (CDC) operation to start. The value can be in date, checkpoint, or LSN/SCN format depending on the source engine. For more information, see Determining a CDC native start point.Conflicts with cdc_start_time."
  type        = string
  default     = null
}

variable "cdc_start_time" {
  description = "The Unix timestamp integer for the start of the Change Data Capture (CDC) operation.Conflicts with cdc_start_position."
  type        = string
  default     = null
}

variable "replication_task_settings" {
  description = "An escaped JSON string that contains the task settings. For a complete list of task settings, see Task Settings for AWS Database Migration Service Tasks."
  type        = string
  default     = null
}

variable "start_replication_task" {
  description = "Whether to run or stop the replication task."
  type        = string
  default     = null
}

