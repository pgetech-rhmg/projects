# Azure Traffic Manager AMBA Variables
# This file contains all variable definitions for Azure Traffic Manager monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Traffic Manager profiles are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != ""
    error_message = "Resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != ""
    error_message = "Action group resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group" {
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "Action group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9 _-]{1,260}$", var.action_group))
    error_message = "Action group name must be 1-260 characters and contain only alphanumeric characters, spaces, underscores, and hyphens."
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
variable "traffic_manager_profile_names" {
  description = "List of Traffic Manager profile names to monitor. Leave empty to disable all alerts. Example: ['tm-prod-profile', 'tm-dev-profile']"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.traffic_manager_profile_names : can(regex("^[a-zA-Z0-9-]{1,63}$", name))
    ])
    error_message = "Traffic Manager profile names must be 1-63 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Traffic Manager operations. Leave empty to disable all alerts. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []
}

# Traffic Manager Alert Thresholds
variable "endpoint_health_threshold" {
  description = "Minimum number of healthy endpoints to maintain service"
  type        = number
  default     = 1

  validation {
    condition     = var.endpoint_health_threshold >= 0 && var.endpoint_health_threshold <= 100
    error_message = "Endpoint health threshold must be between 0 and 100."
  }
}

variable "probe_agent_current_endpoint_state_by_profile_resource_id_threshold" {
  description = "Threshold for probe agent endpoint state monitoring"
  type        = number
  default     = 1

  validation {
    condition     = var.probe_agent_current_endpoint_state_by_profile_resource_id_threshold >= 0 && var.probe_agent_current_endpoint_state_by_profile_resource_id_threshold <= 100
    error_message = "Probe agent current endpoint state threshold must be between 0 and 100."
  }
}

# Alert enable flags
variable "enable_traffic_manager_creation_alert" {
  description = "Enable Traffic Manager profile creation monitoring alert"
  type        = bool
  default     = true
}

variable "enable_traffic_manager_deletion_alert" {
  description = "Enable Traffic Manager profile deletion monitoring alert"
  type        = bool
  default     = true
}

variable "enable_traffic_manager_config_change_alert" {
  description = "Enable Traffic Manager configuration change monitoring alert"
  type        = bool
  default     = true
}

variable "enable_endpoint_operations_alert" {
  description = "Enable Traffic Manager endpoint operations monitoring alert"
  type        = bool
  default     = true
}

variable "enable_endpoint_health_alert" {
  description = "Enable Traffic Manager endpoint health monitoring alert"
  type        = bool
  default     = true
}

variable "enable_probe_agent_monitoring_alert" {
  description = "Enable probe agent current endpoint state monitoring alert"
  type        = bool
  default     = true
}

variable "enable_dns_resolution_failure_alert" {
  description = "Enable DNS resolution failure monitoring alert"
  type        = bool
  default     = true
}

# Time windows
variable "window_duration_short" {
  description = "Short window duration for time-sensitive alerts"
  type        = string
  default     = "PT5M"
}

variable "window_duration_medium" {
  description = "Medium window duration for standard alerts"
  type        = string
  default     = "PT15M"
}

variable "window_duration_long" {
  description = "Long window duration for trend analysis alerts"
  type        = string
  default     = "PT1H"
}

variable "evaluation_frequency_high" {
  description = "High frequency evaluation for critical alerts"
  type        = string
  default     = "PT1M"
}

variable "evaluation_frequency_medium" {
  description = "Medium frequency evaluation for standard alerts"
  type        = string
  default     = "PT5M"
}

variable "evaluation_frequency_low" {
  description = "Low frequency evaluation for informational alerts"
  type        = string
  default     = "PT15M"
}

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Traffic Manager profiles"
  type        = bool
  default     = true
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace for diagnostic logs"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Name of the Event Hub for diagnostic logs"
  type        = string
  default     = ""
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
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID for Log Analytics workspace (leave empty to use current subscription)"
  type        = string
  default     = ""
}
