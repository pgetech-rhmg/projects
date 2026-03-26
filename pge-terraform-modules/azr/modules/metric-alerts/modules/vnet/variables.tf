variable "resource_group_name" {
  description = "The name of the resource group where the VNets are located"
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
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group == "" || length(var.action_group) <= 260
    error_message = "Action group name must not exceed 260 characters."
  }
}

variable "vnet_names" {
  description = "List of Virtual Network names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.vnet_names : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.]*[a-zA-Z0-9_]$", name))
    ])
    error_message = "VNet names must start with alphanumeric, end with alphanumeric or underscore, and contain only alphanumeric, hyphens, underscores, and periods."
  }

  validation {
    condition = alltrue([
      for name in var.vnet_names : length(name) >= 2 && length(name) <= 64
    ])
    error_message = "VNet names must be between 2 and 64 characters long."
  }
}

variable "vnet_if_under_ddos_attack_threshold" {
  description = "Threshold for VNet DDoS attack detection (0 = any attack detected)"
  type        = number
  default     = 0

  validation {
    condition     = var.vnet_if_under_ddos_attack_threshold >= 0 && var.vnet_if_under_ddos_attack_threshold <= 10
    error_message = "DDoS attack threshold must be between 0 and 10. Recommended value is 0 to detect any attack."
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

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Virtual Networks"
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

  validation {
    condition     = var.log_analytics_resource_group_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.()]*[a-zA-Z0-9_]$", var.log_analytics_resource_group_name))
    error_message = "Log Analytics resource group name must start with alphanumeric, end with alphanumeric or underscore, and contain only alphanumeric, hyphens, underscores, periods, and parentheses."
  }
}

variable "eventhub_resource_group_name" {
  description = "Resource group name of the Event Hub namespace"
  type        = string
  default     = ""

  validation {
    condition     = var.eventhub_resource_group_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_.()]*[a-zA-Z0-9_]$", var.eventhub_resource_group_name))
    error_message = "Event Hub resource group name must start with alphanumeric, end with alphanumeric or underscore, and contain only alphanumeric, hyphens, underscores, periods, and parentheses."
  }
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

