# SQL Databases AMBA Variables
# This file contains all variable definitions for SQL Database monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the SQL Databases are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != "" && can(regex("^[a-zA-Z0-9][-a-zA-Z0-9._]*[a-zA-Z0-9_]$", var.resource_group_name))
    error_message = "Resource group name must not be empty and must follow Azure naming conventions (alphanumerics, hyphens, underscores, and periods)."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != "" && can(regex("^[a-zA-Z0-9][-a-zA-Z0-9._]*[a-zA-Z0-9_]$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must not be empty and must follow Azure naming conventions."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "Action group name must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply to alert resources"
  type        = map(string)
  default = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}

# Resource-specific variables
variable "sql_database_names" {
  description = "List of SQL Database names to monitor (format: server-name/database-name)"
  type        = list(string)
  default     = []
  # Example: ["pge-sqlserver-prod/app-database", "pge-sqlserver-dev/test-database"]

  validation {
    condition     = length(var.sql_database_names) > 0
    error_message = "At least one SQL Database must be specified."
  }

  validation {
    condition     = alltrue([for db in var.sql_database_names : can(regex("^[^/]+/[^/]+$", db))])
    error_message = "SQL Database names must be in format 'server-name/database-name'."
  }
}

# Performance alert thresholds
variable "cpu_percent_threshold" {
  description = "Threshold for CPU percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_percent_threshold >= 0 && var.cpu_percent_threshold <= 100
    error_message = "CPU percent threshold must be between 0 and 100."
  }
}

variable "physical_data_read_percent_threshold" {
  description = "Threshold for physical data read percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.physical_data_read_percent_threshold >= 0 && var.physical_data_read_percent_threshold <= 100
    error_message = "Physical data read percent threshold must be between 0 and 100."
  }
}

variable "log_write_percent_threshold" {
  description = "Threshold for log write percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.log_write_percent_threshold >= 0 && var.log_write_percent_threshold <= 100
    error_message = "Log write percent threshold must be between 0 and 100."
  }
}

variable "sessions_percent_threshold" {
  description = "Threshold for sessions percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.sessions_percent_threshold >= 0 && var.sessions_percent_threshold <= 100
    error_message = "Sessions percent threshold must be between 0 and 100."
  }
}

variable "workers_percent_threshold" {
  description = "Threshold for workers percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.workers_percent_threshold >= 0 && var.workers_percent_threshold <= 100
    error_message = "Workers percent threshold must be between 0 and 100."
  }
}

variable "sqlserver_process_core_percent_threshold" {
  description = "Threshold for SQL Server process core percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.sqlserver_process_core_percent_threshold >= 0 && var.sqlserver_process_core_percent_threshold <= 100
    error_message = "SQL Server process core percent threshold must be between 0 and 100."
  }
}

variable "tempdb_log_used_percent_threshold" {
  description = "Threshold for TempDB log used percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.tempdb_log_used_percent_threshold >= 0 && var.tempdb_log_used_percent_threshold <= 100
    error_message = "TempDB log used percent threshold must be between 0 and 100."
  }
}

# Storage alert thresholds
variable "storage_percent_threshold" {
  description = "Threshold for storage percentage alert"
  type        = number
  default     = 90

  validation {
    condition     = var.storage_percent_threshold >= 0 && var.storage_percent_threshold <= 100
    error_message = "Storage percent threshold must be between 0 and 100."
  }
}

variable "storage_used_bytes_threshold" {
  description = "Threshold for storage used bytes alert (in bytes)"
  type        = number
  default     = 107374182400 # 100GB in bytes

  validation {
    condition     = var.storage_used_bytes_threshold > 0
    error_message = "Storage used bytes threshold must be greater than 0."
  }
}

variable "xtp_storage_percent_threshold" {
  description = "Threshold for In-Memory XTP storage percentage alert"
  type        = number
  default     = 90

  validation {
    condition     = var.xtp_storage_percent_threshold >= 0 && var.xtp_storage_percent_threshold <= 100
    error_message = "XTP storage percent threshold must be between 0 and 100."
  }
}

# Connection alert thresholds
variable "connection_successful_threshold" {
  description = "Minimum threshold for successful connections (below this triggers alert)"
  type        = number
  default     = 10

  validation {
    condition     = var.connection_successful_threshold >= 0
    error_message = "Connection successful threshold must be greater than or equal to 0."
  }
}

variable "connection_failed_threshold" {
  description = "Threshold for failed connections alert"
  type        = number
  default     = 5

  validation {
    condition     = var.connection_failed_threshold >= 0
    error_message = "Connection failed threshold must be greater than or equal to 0."
  }
}

# Database health thresholds
variable "deadlock_threshold" {
  description = "Threshold for deadlock alert (deadlocks per minute)"
  type        = number
  default     = 1

  validation {
    condition     = var.deadlock_threshold >= 0
    error_message = "Deadlock threshold must be greater than or equal to 0."
  }
}

# =======================================================================================
# Diagnostic Settings Variables
# =======================================================================================

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings to send activity logs to Event Hub and security logs to Log Analytics"
  type        = bool
  default     = true
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace for activity logs"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Name of the Event Hub for activity logs"
  type        = string
  default     = ""
}

variable "eventhub_authorization_rule_name" {
  description = "Name of the Event Hub authorization rule"
  type        = string
  default     = "RootManageSharedAccessKey"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for security logs"
  type        = string
  default     = ""
}

variable "log_analytics_resource_group_name" {
  description = "Resource group name of the Log Analytics workspace"
  type        = string
  default     = ""
}

variable "eventhub_resource_group_name" {
  description = "Resource group name of the Event Hub namespace"
  type        = string
  default     = ""
}

variable "eventhub_subscription_id" {
  description = "Subscription ID where the Event Hub namespace is located (leave empty to use current subscription)"
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID where the Log Analytics workspace is located (leave empty to use current subscription)"
  type        = string
  default     = ""
}
