# SQL Managed Instance AMBA Variables
# This file contains all variable definitions for SQL Managed Instance monitoring alerts

# Common variables
variable "action_group" {
  description = "Name of the action group for notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "Action group name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group name where the action group is located"
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
variable "sql_mi_names" {
  description = "List of SQL Managed Instance names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.sql_mi_names) > 0
    error_message = "At least one SQL Managed Instance must be specified."
  }
}

variable "sql_mi_resource_group" {
  description = "Resource group name where SQL Managed Instances are located"
  type        = string
  default     = "rg-amba"

  validation {
    condition     = var.sql_mi_resource_group != "" && can(regex("^[a-zA-Z0-9][-a-zA-Z0-9._]*[a-zA-Z0-9_]$", var.sql_mi_resource_group))
    error_message = "SQL MI resource group name must not be empty and must follow Azure naming conventions."
  }
}

# Alert configuration
variable "evaluation_frequency" {
  description = "Frequency of alert evaluation"
  type        = string
  default     = "PT5M" # 5 minutes
}

variable "window_size" {
  description = "Window size for alert evaluation"
  type        = string
  default     = "PT15M" # 15 minutes
}

# Alert thresholds
variable "cpu_warning_threshold" {
  description = "CPU usage warning threshold (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_warning_threshold >= 0 && var.cpu_warning_threshold <= 100
    error_message = "CPU warning threshold must be between 0 and 100."
  }
}

variable "cpu_critical_threshold" {
  description = "CPU usage critical threshold (percentage)"
  type        = number
  default     = 90

  validation {
    condition     = var.cpu_critical_threshold >= 0 && var.cpu_critical_threshold <= 100
    error_message = "CPU critical threshold must be between 0 and 100."
  }
}

variable "storage_warning_threshold" {
  description = "Storage usage warning threshold (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.storage_warning_threshold >= 0 && var.storage_warning_threshold <= 100
    error_message = "Storage warning threshold must be between 0 and 100."
  }
}

variable "storage_critical_threshold" {
  description = "Storage usage critical threshold (percentage)"
  type        = number
  default     = 90

  validation {
    condition     = var.storage_critical_threshold >= 0 && var.storage_critical_threshold <= 100
    error_message = "Storage critical threshold must be between 0 and 100."
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
