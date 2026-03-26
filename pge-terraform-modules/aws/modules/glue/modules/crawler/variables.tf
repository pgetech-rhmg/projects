# Variables for Glue Crawler

variable "glue_crawler_name" {
  description = "Name of the crawler."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]*$", var.glue_crawler_name))
    error_message = "Error! Name may contain letters (A-Z), numbers (0-9), hyphens (-), or underscores (_)."
  }
}

variable "glue_crawler_database_name" {
  description = "Glue database where results are written."
  type        = string
}

variable "glue_crawler_role" {
  description = "The IAM role friendly name (including path without leading slash), or ARN of an IAM role, used by the crawler to access other resources."
  type        = string
}

variable "glue_crawler_security_configuration" {
  description = "The name of Security Configuration to be used by the crawler"
  type        = string
  default     = null
}

variable "glue_crawler_classifiers" {
  description = "List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification."
  type        = list(string)
  default     = null
}

variable "glue_crawler_configuration" {
  description = "JSON string of configuration information."
  type        = string
  default     = null
}

variable "glue_crawler_description" {
  description = "Description of the crawler."
  type        = string
  default     = null
}

variable "dynamodb_target" {
  description = "List of nested DynamoDB target arguments."
  type        = list(map(string))
  default     = []

  validation {
    condition     = alltrue(flatten([for val in var.dynamodb_target : [for ki, vi in val : can(regex("^[a-zA-Z0-9_.-]*$", vi)) if ki == "path"]]))
    error_message = "Error! Enter the path to the Amazon dynamodb target."
  }

  validation {
    condition     = alltrue(flatten([for val in var.dynamodb_target : [for ki, vi in val : vi >= 0.1 && vi <= 1.5 if ki == "scan_rate"]]))
    error_message = "Error! The valid values for scan_rate are between 0.1 to 1.5."
  }
}

variable "jdbc_target" {
  description = "List of nested JDBC target arguments."
  type        = list(any)
  default     = []
}

variable "s3_target" {
  description = "List of nested Amazon S3 target arguments."
  type        = list(any)
  default     = []

  validation {
    condition     = alltrue(flatten([for val in var.s3_target : [for ki, vi in val : can(regex("^s3://+", vi)) if ki == "path"]]))
    error_message = "Error! Enter a valid path to the Amazon S3 target."
  }

  validation {
    condition     = alltrue(flatten([for val in var.s3_target : [for ki, vi in val : vi >= 1 && vi <= 249 if ki == "sample_size"]]))
    error_message = "Error! The valid values for s3_target sample_size are between 1 and 249."
  }
}

variable "catalog_target" {
  description = "List of nested Amazon catalog target arguments."
  type        = list(map(string))
  default     = []
}

variable "mongodb_target" {
  description = "List nested MongoDB target arguments."
  type        = list(map(string))
  default     = []
}

variable "delta_target" {
  description = "List nested delta target arguments."
  type        = list(map(string))
  default     = []
}

variable "glue_crawler_schema_change_policy" {
  description = "Policy for the crawler's update and deletion behavior."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for ki, vi in var.glue_crawler_schema_change_policy : contains(["LOG", "DELETE_FROM_DATABASE", "DEPRECATE_IN_DATABASE"], vi) if ki == "delete_behavior"])
    error_message = "Error! Valid values for delete_behavior: LOG, DELETE_FROM_DATABASE, or DEPRECATE_IN_DATABASE."
  }

  validation {
    condition     = alltrue([for ki, vi in var.glue_crawler_schema_change_policy : contains(["LOG", "UPDATE_IN_DATABASE"], vi) if ki == "update_behavior"])
    error_message = "Error! Valid values for update_behavior: LOG or UPDATE_IN_DATABASE."
  }
}

variable "glue_crawler_lineage_configuration" {
  description = "Specifies data lineage configuration settings for the crawler. "
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for ki, vi in var.glue_crawler_lineage_configuration : contains(["ENABLE", "DISABLE"], vi) if ki == "crawler_lineage_settings"])
    error_message = "Error! Valid values for crawler_lineage_settings: ENABLE and DISABLE."
  }
}

variable "glue_crawler_recrawl_policy" {
  description = "A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for ki, vi in var.glue_crawler_recrawl_policy : contains(["CRAWL_EVENT_MODE", "CRAWL_EVERYTHING", "CRAWL_NEW_FOLDERS_ONLY"], vi) if ki == "recrawl_behavior"])
    error_message = "Error! Valid values for crawler_lineage_settings: CRAWL_EVENT_MODE, CRAWL_EVERYTHING and CRAWL_NEW_FOLDERS_ONLY."
  }
}

variable "glue_crawler_schedule" {
  description = "A cron expression used to specify the schedule. For more information, see Time-Based Schedules for Jobs and Crawlers."
  type        = string
  default     = null
}

variable "glue_crawler_table_prefix" {
  description = "The table prefix used for catalog tables that are created."
  type        = string
  default     = null

  validation {
    condition     = var.glue_crawler_table_prefix == null || can(regex("^[a-zA-Z0-9_]*$", var.glue_crawler_table_prefix))
    error_message = "Error! Table name can only contain alphanumeric characters and underscores (_)."
  }
}

# Variable for tags

variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}