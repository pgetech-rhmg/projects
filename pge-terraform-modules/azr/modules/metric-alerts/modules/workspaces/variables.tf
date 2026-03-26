# Log Analytics Workspaces AMBA Variables
# This file contains all variable definitions for Log Analytics Workspaces monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Log Analytics Workspaces are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.()]*[a-zA-Z0-9_]$", var.resource_group_name))
    error_message = "Resource group name must start with alphanumeric, end with alphanumeric or underscore, and contain only alphanumeric, hyphens, underscores, periods, and parentheses."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.()]*[a-zA-Z0-9_]$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must start with alphanumeric, end with alphanumeric or underscore, and contain only alphanumeric, hyphens, underscores, periods, and parentheses."
  }
}

variable "action_group" {
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group == "" || length(var.action_group) <= 260
    error_message = "Action group name must not exceed 260 characters."
  }
}

variable "location" {
  description = "Azure region location for scheduled query rules"
  type        = string
  default     = "West US 2"
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
variable "workspace_names" {
  description = "List of Log Analytics Workspace names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.workspace_names : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", name))
    ])
    error_message = "Workspace names must start and end with alphanumeric, and contain only alphanumeric and hyphens."
  }

  validation {
    condition = alltrue([
      for name in var.workspace_names : length(name) >= 4 && length(name) <= 63
    ])
    error_message = "Workspace names must be between 4 and 63 characters long."
  }
}

variable "workspace_custom_tables" {
  description = "List of custom table names to monitor for ingestion"
  type        = list(string)
  default     = ["CustomTable1_CL", "CustomTable2_CL"]
}

# Alert enable flags
variable "enable_workspace_heartbeat_alert" {
  description = "Enable heartbeat monitoring alert"
  type        = bool
  default     = true
}

variable "enable_workspace_query_performance_alert" {
  description = "Enable query performance monitoring alert"
  type        = bool
  default     = true
}

variable "enable_workspace_data_retention_alert" {
  description = "Enable data retention monitoring alert"
  type        = bool
  default     = true
}

variable "enable_workspace_error_rate_alert" {
  description = "Enable error rate monitoring alert"
  type        = bool
  default     = true
}

variable "enable_workspace_agent_connection_alert" {
  description = "Enable agent connection monitoring alert"
  type        = bool
  default     = true
}

variable "enable_workspace_custom_table_alert" {
  description = "Enable custom table ingestion monitoring alert"
  type        = bool
  default     = true
}

# Alert thresholds
variable "workspace_heartbeat_threshold" {
  description = "Threshold for heartbeat alert (number of missing heartbeats)"
  type        = number
  default     = 5

  validation {
    condition     = var.workspace_heartbeat_threshold >= 1 && var.workspace_heartbeat_threshold <= 100
    error_message = "Heartbeat threshold must be between 1 and 100."
  }
}

variable "workspace_query_performance_threshold" {
  description = "Threshold for query performance alert (milliseconds)"
  type        = number
  default     = 30000

  validation {
    condition     = var.workspace_query_performance_threshold >= 1000 && var.workspace_query_performance_threshold <= 300000
    error_message = "Query performance threshold must be between 1,000ms (1 second) and 300,000ms (5 minutes)."
  }
}

variable "workspace_error_rate_threshold" {
  description = "Threshold for error rate alert (percentage)"
  type        = number
  default     = 10

  validation {
    condition     = var.workspace_error_rate_threshold >= 1 && var.workspace_error_rate_threshold <= 100
    error_message = "Error rate threshold must be between 1 and 100 percent."
  }
}

variable "workspace_agent_connection_threshold" {
  description = "Threshold for agent connection issues"
  type        = number
  default     = 5

  validation {
    condition     = var.workspace_agent_connection_threshold >= 1 && var.workspace_agent_connection_threshold <= 100
    error_message = "Agent connection threshold must be between 1 and 100."
  }
}

variable "workspace_custom_table_threshold" {
  description = "Threshold for custom table ingestion alert (MB)"
  type        = number
  default     = 100

  validation {
    condition     = var.workspace_custom_table_threshold >= 1 && var.workspace_custom_table_threshold <= 10000
    error_message = "Custom table threshold must be between 1 MB and 10,000 MB."
  }
}

# Data retention settings
variable "workspace_retention_days" {
  description = "Data retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = var.workspace_retention_days >= 30 && var.workspace_retention_days <= 730
    error_message = "Retention days must be between 30 and 730 days (2 years)."
  }
}

variable "workspace_retention_warning_days" {
  description = "Days before retention period to warn"
  type        = number
  default     = 7

  validation {
    condition     = var.workspace_retention_warning_days >= 1 && var.workspace_retention_warning_days <= 90
    error_message = "Retention warning days must be between 1 and 90 days."
  }

  validation {
    condition     = var.workspace_retention_warning_days < var.workspace_retention_days
    error_message = "Retention warning days must be less than retention days."
  }
}

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Log Analytics Workspaces"
  type        = bool
  default     = true
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace for diagnostic logs"
  type        = string
  default     = ""

  validation {
    condition     = var.eventhub_namespace_name == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.eventhub_namespace_name))
    error_message = "Event Hub namespace name must start with a letter, end with alphanumeric, and contain only alphanumeric and hyphens."
  }

  validation {
    condition     = var.eventhub_namespace_name == "" || (length(var.eventhub_namespace_name) >= 6 && length(var.eventhub_namespace_name) <= 50)
    error_message = "Event Hub namespace name must be between 6 and 50 characters long."
  }
}

variable "eventhub_name" {
  description = "Name of the Event Hub for diagnostic logs"
  type        = string
  default     = ""

  validation {
    condition     = var.eventhub_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.]*[a-zA-Z0-9]$", var.eventhub_name))
    error_message = "Event Hub name must start and end with alphanumeric, and contain only alphanumeric, hyphens, underscores, and periods."
  }

  validation {
    condition     = var.eventhub_name == "" || (length(var.eventhub_name) >= 1 && length(var.eventhub_name) <= 256)
    error_message = "Event Hub name must be between 1 and 256 characters long."
  }
}

variable "eventhub_authorization_rule_name" {
  description = "Name of the Event Hub authorization rule"
  type        = string
  default     = "RootManageSharedAccessKey"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for diagnostic logs"
  type        = string
  default     = ""

  validation {
    condition     = var.log_analytics_workspace_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.log_analytics_workspace_name))
    error_message = "Log Analytics workspace name must start and end with alphanumeric, and contain only alphanumeric and hyphens."
  }

  validation {
    condition     = var.log_analytics_workspace_name == "" || (length(var.log_analytics_workspace_name) >= 4 && length(var.log_analytics_workspace_name) <= 63)
    error_message = "Log Analytics workspace name must be between 4 and 63 characters long."
  }
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
  description = "Subscription ID for Event Hub (leave empty to use current subscription)"
  type        = string
  default     = ""

  validation {
    condition     = var.eventhub_subscription_id == "" || can(regex("^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$", var.eventhub_subscription_id))
    error_message = "Event Hub subscription ID must be a valid GUID format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) or empty."
  }
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID for Log Analytics workspace (leave empty to use current subscription)"
  type        = string
  default     = ""

  validation {
    condition     = var.log_analytics_subscription_id == "" || can(regex("^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$", var.log_analytics_subscription_id))
    error_message = "Log Analytics subscription ID must be a valid GUID format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) or empty."
  }
}

