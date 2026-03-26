# App Service Sites AMBA Variables
# This file contains all variable definitions for App Service Sites monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the App Service sites are located"
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
variable "windows_site_names" {
  description = "List of Windows App Service site names to monitor"
  type        = list(string)
  default     = []
}

variable "linux_site_names" {
  description = "List of Linux App Service site names to monitor"
  type        = list(string)
  default     = []
}

# Alert thresholds
variable "availability_threshold" {
  description = "Threshold for availability alert (percentage)"
  type        = number
  default     = 99

  validation {
    condition     = var.availability_threshold >= 0 && var.availability_threshold <= 100
    error_message = "Availability threshold must be between 0 and 100 percent."
  }
}

variable "response_time_threshold" {
  description = "Threshold for average response time alert (seconds)"
  type        = number
  default     = 5

  validation {
    condition     = var.response_time_threshold > 0
    error_message = "Response time threshold must be greater than 0 seconds."
  }
}

variable "response_time_critical_threshold" {
  description = "Critical threshold for response time alert (seconds)"
  type        = number
  default     = 10

  validation {
    condition     = var.response_time_critical_threshold > 0
    error_message = "Response time critical threshold must be greater than 0 seconds."
  }
}

variable "http_4xx_threshold" {
  description = "Threshold for HTTP 4xx errors alert (count per minute)"
  type        = number
  default     = 10

  validation {
    condition     = var.http_4xx_threshold >= 0
    error_message = "HTTP 4xx threshold must be greater than or equal to 0."
  }
}

variable "http_5xx_threshold" {
  description = "Threshold for HTTP 5xx errors alert (count per minute)"
  type        = number
  default     = 5

  validation {
    condition     = var.http_5xx_threshold >= 0
    error_message = "HTTP 5xx threshold must be greater than or equal to 0."
  }
}

variable "request_rate_threshold" {
  description = "Threshold for request rate alert (requests per minute)"
  type        = number
  default     = 1000

  validation {
    condition     = var.request_rate_threshold >= 0
    error_message = "Request rate threshold must be greater than or equal to 0."
  }
}

variable "cpu_time_threshold" {
  description = "Threshold for CPU time alert (seconds)"
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_time_threshold > 0
    error_message = "CPU time threshold must be greater than 0 seconds."
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
