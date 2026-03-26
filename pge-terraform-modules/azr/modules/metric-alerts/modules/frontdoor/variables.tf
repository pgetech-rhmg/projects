# Azure Front Door AMBA Variables
# This file contains all variable definitions for Azure Front Door monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Front Door resources are located"
  type        = string
  default     = ""

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = length(var.action_group_resource_group_name) > 0 && length(var.action_group_resource_group_name) <= 90
    error_message = "Action group resource group name must be between 1 and 90 characters."
  }
}

variable "action_group" {
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = length(var.action_group) > 0
    error_message = "Action group name cannot be empty."
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
variable "front_door_names" {
  description = "List of Front Door names to monitor. Leave empty to disable Front Door alerts. Example: ['frontdoor-prod', 'frontdoor-dev']"
  type        = list(string)
  default     = []
}

variable "subscription_ids" {
  description = "List of subscription IDs where Front Door resources are located"
  type        = list(string)
  default     = []
}

variable "auto_detect_front_door_type" {
  description = "Automatically detect Front Door type (Classic vs Standard/Premium). Set to false to use manual detection."
  type        = bool
  default     = true
}

variable "front_door_type" {
  description = "Manual override for Front Door type: 'classic' for Microsoft.Network/frontDoors or 'standard' for Microsoft.Cdn/profiles. Only used when auto_detect_front_door_type is false."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["classic", "standard"], var.front_door_type)
    error_message = "Front Door type must be either 'classic' or 'standard'."
  }
}

# Enable/disable alert categories
variable "enable_performance_alerts" {
  description = "Enable Front Door performance monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_availability_alerts" {
  description = "Enable Front Door availability monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_security_alerts" {
  description = "Enable Front Door security monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_cost_alerts" {
  description = "Enable Front Door cost monitoring alerts"
  type        = bool
  default     = true
}

# Performance alert thresholds
variable "response_time_threshold" {
  description = "Response time threshold in milliseconds for Front Door alerts"
  type        = number
  default     = 5000

  validation {
    condition     = var.response_time_threshold > 0
    error_message = "Response time threshold must be greater than 0."
  }
}

variable "backend_health_threshold" {
  description = "Backend health percentage threshold"
  type        = number
  default     = 80

  validation {
    condition     = var.backend_health_threshold > 0 && var.backend_health_threshold <= 100
    error_message = "Backend health threshold must be between 0 and 100."
  }
}

variable "request_count_threshold" {
  description = "Request count threshold for high traffic alerts"
  type        = number
  default     = 10000

  validation {
    condition     = var.request_count_threshold > 0
    error_message = "Request count threshold must be greater than 0."
  }
}

variable "error_rate_threshold" {
  description = "Error rate percentage threshold"
  type        = number
  default     = 5

  validation {
    condition     = var.error_rate_threshold > 0 && var.error_rate_threshold <= 100
    error_message = "Error rate threshold must be between 0 and 100."
  }
}

# Availability alert thresholds
variable "availability_threshold" {
  description = "Availability percentage threshold"
  type        = number
  default     = 99

  validation {
    condition     = var.availability_threshold > 0 && var.availability_threshold <= 100
    error_message = "Availability threshold must be between 0 and 100."
  }
}

variable "health_probe_failures_threshold" {
  description = "Health probe failures threshold"
  type        = number
  default     = 3

  validation {
    condition     = var.health_probe_failures_threshold >= 0
    error_message = "Health probe failures threshold must be greater than or equal to 0."
  }
}

# Security alert thresholds
variable "waf_blocked_requests_threshold" {
  description = "WAF blocked requests threshold for security alerts"
  type        = number
  default     = 100

  validation {
    condition     = var.waf_blocked_requests_threshold >= 0
    error_message = "WAF blocked requests threshold must be greater than or equal to 0."
  }
}

variable "ddos_attack_threshold" {
  description = "DDoS attack requests threshold"
  type        = number
  default     = 1000
}

# Cost alert thresholds
variable "bandwidth_cost_threshold" {
  description = "Bandwidth usage threshold in GB for cost alerts"
  type        = number
  default     = 1000
}

#=============================================================================
# USAGE EXAMPLES FOR BOTH FRONT DOOR TYPES
#=============================================================================

# Example 1: Front Door Standard/Premium (Most Common)
# front_door_names = ["my-standard-profile"]
# front_door_type = "standard"      # Uses Microsoft.Cdn/profiles
# auto_detect_front_door_type = true

# Example 2: Classic Front Door (Legacy)
# front_door_names = ["my-classic-frontdoor"] 
# front_door_type = "classic"       # Uses Microsoft.Network/frontDoors
# auto_detect_front_door_type = false

# Example 3: Multiple Front Doors (Mixed Types - Advanced)
# You can deploy this module twice with different configurations:
# Module 1: Standard/Premium Front Doors
# Module 2: Classic Front Doors

# The module automatically handles the differences between:
# - Resource providers (Microsoft.Cdn vs Microsoft.Network)
# - Metric namespaces (Microsoft.Cdn/profiles vs Microsoft.Network/frontDoors)  
# - Metric names (OriginHealthPercentage vs BackendHealthPercentage)
# - Resource scopes and paths

variable "request_cost_threshold" {
  description = "Request count threshold for cost alerts"
  type        = number
  default     = 1000000
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
  description = "Subscription ID where the Event Hub namespace is located. If empty, uses the current subscription."
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID where the Log Analytics workspace is located. If empty, uses the current subscription."
  type        = string
  default     = ""
}
