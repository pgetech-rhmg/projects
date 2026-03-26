# Azure Function Apps AMBA Variables
# This file contains all variable definitions for Azure Function Apps monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Function Apps are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name == "" || can(regex("^[a-zA-Z0-9._\\-()]+$", var.resource_group_name))
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
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group == "" || length(var.action_group) <= 260
    error_message = "Action group name must be 260 characters or less."
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
variable "windows_function_app_names" {
  description = "List of Windows Function App names to monitor. Leave empty to disable Windows Function App alerts. Example: ['func-win-prod', 'func-win-dev']"
  type        = list(string)
  default     = []
}

variable "linux_function_app_names" {
  description = "List of Linux Function App names to monitor. Leave empty to disable Linux Function App alerts. Example: ['func-linux-prod', 'func-linux-dev']"
  type        = list(string)
  default     = []
}

variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Function App operations. Leave empty to disable all alerts. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []
}

# Function App Alert Thresholds
variable "function_execution_count_threshold" {
  description = "Threshold for function execution count alert"
  type        = number
  default     = 1000

  validation {
    condition     = var.function_execution_count_threshold > 0
    error_message = "Function execution count threshold must be greater than 0."
  }
}

variable "function_execution_units_threshold" {
  description = "Threshold for function execution units alert"
  type        = number
  default     = 10000

  validation {
    condition     = var.function_execution_units_threshold > 0
    error_message = "Function execution units threshold must be greater than 0."
  }
}

variable "average_memory_working_set_threshold" {
  description = "Threshold for average memory working set alert (bytes)"
  type        = number
  default     = 1073741824 # 1GB in bytes

  validation {
    condition     = var.average_memory_working_set_threshold > 0
    error_message = "Average memory working set threshold must be greater than 0."
  }
}

variable "memory_working_set_threshold" {
  description = "Threshold for memory working set alert (bytes)"
  type        = number
  default     = 1073741824 # 1GB in bytes

  validation {
    condition     = var.memory_working_set_threshold > 0
    error_message = "Memory working set threshold must be greater than 0."
  }
}

variable "http_5xx_threshold" {
  description = "Threshold for HTTP 5xx errors alert (count)"
  type        = number
  default     = 5

  validation {
    condition     = var.http_5xx_threshold > 0
    error_message = "HTTP 5xx threshold must be greater than 0."
  }
}

variable "http_4xx_threshold" {
  description = "Threshold for HTTP 4xx errors alert (count)"
  type        = number
  default     = 10

  validation {
    condition     = var.http_4xx_threshold > 0
    error_message = "HTTP 4xx threshold must be greater than 0."
  }
}

variable "response_time_threshold" {
  description = "Threshold for average response time alert (seconds)"
  type        = number
  default     = 5

  validation {
    condition     = var.response_time_threshold > 0
    error_message = "Response time threshold must be greater than 0."
  }
}

variable "response_time_critical_threshold" {
  description = "Critical threshold for response time alert (seconds)"
  type        = number
  default     = 10

  validation {
    condition     = var.response_time_critical_threshold > 0
    error_message = "Response time critical threshold must be greater than 0."
  }
}

variable "requests_threshold" {
  description = "Threshold for total requests alert"
  type        = number
  default     = 1000

  validation {
    condition     = var.requests_threshold > 0
    error_message = "Requests threshold must be greater than 0."
  }
}

variable "io_read_ops_threshold" {
  description = "Threshold for IO read operations per second"
  type        = number
  default     = 100

  validation {
    condition     = var.io_read_ops_threshold > 0
    error_message = "I/O read operations threshold must be greater than 0."
  }
}

variable "io_write_ops_threshold" {
  description = "Threshold for IO write operations per second"
  type        = number
  default     = 100

  validation {
    condition     = var.io_write_ops_threshold > 0
    error_message = "I/O write operations threshold must be greater than 0."
  }
}

variable "private_bytes_threshold" {
  description = "Threshold for private bytes alert (bytes)"
  type        = number
  default     = 1073741824 # 1GB in bytes

  validation {
    condition     = var.private_bytes_threshold > 0
    error_message = "Private bytes threshold must be greater than 0."
  }
}

variable "gen_0_collections_threshold" {
  description = "Threshold for Gen 0 garbage collections"
  type        = number
  default     = 100

  validation {
    condition     = var.gen_0_collections_threshold > 0
    error_message = "Gen 0 collections threshold must be greater than 0."
  }
}

variable "gen_1_collections_threshold" {
  description = "Threshold for Gen 1 garbage collections"
  type        = number
  default     = 50

  validation {
    condition     = var.gen_1_collections_threshold > 0
    error_message = "Gen 1 collections threshold must be greater than 0."
  }
}

variable "gen_2_collections_threshold" {
  description = "Threshold for Gen 2 garbage collections"
  type        = number
  default     = 10

  validation {
    condition     = var.gen_2_collections_threshold > 0
    error_message = "Gen 2 collections threshold must be greater than 0."
  }
}

# Alert enable flags
variable "enable_function_execution_alerts" {
  description = "Enable Function execution monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_performance_alerts" {
  description = "Enable Function App performance alerts (CPU, memory, response time)"
  type        = bool
  default     = true
}

variable "enable_error_alerts" {
  description = "Enable Function App error alerts (HTTP 4xx, 5xx)"
  type        = bool
  default     = true
}

variable "enable_resource_alerts" {
  description = "Enable Function App resource utilization alerts (IO, memory, GC)"
  type        = bool
  default     = true
}

variable "enable_activity_log_alerts" {
  description = "Enable Function App activity log alerts (creation, deletion, configuration changes)"
  type        = bool
  default     = true
}

variable "enable_function_app_creation_alert" {
  description = "Enable Function App creation monitoring alert"
  type        = bool
  default     = true
}

variable "enable_function_app_deletion_alert" {
  description = "Enable Function App deletion monitoring alert"
  type        = bool
  default     = true
}

variable "enable_function_app_config_change_alert" {
  description = "Enable Function App configuration change monitoring alert"
  type        = bool
  default     = true
}

variable "enable_function_stopped_alert" {
  description = "Enable Function App stopped monitoring alert"
  type        = bool
  default     = true
}

# Time windows and frequencies
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
