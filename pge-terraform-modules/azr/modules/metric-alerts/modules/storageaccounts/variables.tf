# Storage Accounts AMBA Variables
# This file contains all variable definitions for Storage Account monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the storage accounts are located"
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
variable "storage_account_names" {
  description = "List of Storage Account names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.storage_account_names) > 0
    error_message = "At least one Storage Account must be specified."
  }

  validation {
    condition     = alltrue([for name in var.storage_account_names : can(regex("^[a-z0-9]{3,24}$", name))])
    error_message = "Storage Account names must be lowercase alphanumeric and between 3-24 characters."
  }
}

# Alert thresholds
variable "storage_availability_threshold" {
  description = "Threshold for storage availability alert (percentage)"
  type        = number
  default     = 99

  validation {
    condition     = var.storage_availability_threshold >= 0 && var.storage_availability_threshold <= 100
    error_message = "Storage availability threshold must be between 0 and 100."
  }
}

variable "storage_capacity_threshold" {
  description = "Threshold for storage capacity alert (percentage of maximum capacity)"
  type        = number
  default     = 90

  validation {
    condition     = var.storage_capacity_threshold >= 0 && var.storage_capacity_threshold <= 100
    error_message = "Storage capacity threshold must be between 0 and 100."
  }
}

variable "storage_transaction_threshold" {
  description = "Threshold for storage transaction alert (transactions per minute)"
  type        = number
  default     = 10000

  validation {
    condition     = var.storage_transaction_threshold >= 0
    error_message = "Storage transaction threshold must be greater than or equal to 0."
  }
}

variable "storage_latency_threshold" {
  description = "Threshold for storage E2E latency alert (milliseconds)"
  type        = number
  default     = 1000

  validation {
    condition     = var.storage_latency_threshold > 0
    error_message = "Storage latency threshold must be greater than 0."
  }
}

variable "storage_server_latency_threshold" {
  description = "Threshold for storage server latency alert (milliseconds)"
  type        = number
  default     = 100

  validation {
    condition     = var.storage_server_latency_threshold > 0
    error_message = "Storage server latency threshold must be greater than 0."
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
