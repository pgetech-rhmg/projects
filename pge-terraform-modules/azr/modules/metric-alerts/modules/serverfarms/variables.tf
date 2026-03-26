# App Service Plan (Server Farms) AMBA Variables
# This file contains all variable definitions for App Service Plan monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the serverfarms are located"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9._\\-()]+$", var.resource_group_name)) || var.resource_group_name == ""
    error_message = "Resource group name must contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._\\-()]+$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_\\-]+$", var.action_group)) || var.action_group == ""
    error_message = "Action group name must contain only alphanumeric characters, underscores, and hyphens."
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
variable "serverfarm_names" {
  description = "List of App Service Plan (serverfarm) names to monitor"
  type        = list(string)
  default     = []
}

# Alert thresholds
variable "cpu_percentage_threshold" {
  description = "Threshold for CPU percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_percentage_threshold > 0 && var.cpu_percentage_threshold <= 100
    error_message = "CPU percentage threshold must be between 0 and 100."
  }
}

variable "memory_percentage_threshold" {
  description = "Threshold for memory percentage alert"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_percentage_threshold > 0 && var.memory_percentage_threshold <= 100
    error_message = "Memory percentage threshold must be between 0 and 100."
  }
}

variable "disk_queue_length_threshold" {
  description = "Threshold for disk queue length alert"
  type        = number
  default     = 32

  validation {
    condition     = var.disk_queue_length_threshold > 0
    error_message = "Disk queue length threshold must be greater than 0."
  }
}

variable "http_queue_length_threshold" {
  description = "Threshold for HTTP queue length alert"
  type        = number
  default     = 100

  validation {
    condition     = var.http_queue_length_threshold > 0
    error_message = "HTTP queue length threshold must be greater than 0."
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
  default     = "rg-amba"
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
