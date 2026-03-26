# Event Hub AMBA Variables
# This file contains all variable definitions for Event Hub monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "Name of the resource group where Event Hub resources are located"
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

# Event Hub Namespace Names
variable "eventhub_namespace_names" {
  description = "List of Event Hub namespace names to monitor"
  type        = list(string)
  default     = []
}

# Event Hub Names (for individual Event Hub monitoring)
variable "eventhub_names" {
  description = "List of individual Event Hub names to monitor (requires eventhub_default_namespace)"
  type        = list(string)
  default     = []
}

variable "eventhub_default_namespace" {
  description = "Default namespace for individual Event Hub monitoring (required when eventhub_names is specified)"
  type        = string
  default     = ""
}

# Event Hub Namespace Alert Feature Flags
variable "enable_eventhub_incoming_requests_alert" {
  description = "Enable Event Hub incoming requests alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_successful_requests_alert" {
  description = "Enable Event Hub successful requests alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_server_errors_alert" {
  description = "Enable Event Hub server errors alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_user_errors_alert" {
  description = "Enable Event Hub user errors alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_throttled_requests_alert" {
  description = "Enable Event Hub throttled requests alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_incoming_messages_alert" {
  description = "Enable Event Hub incoming messages alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_outgoing_messages_alert" {
  description = "Enable Event Hub outgoing messages alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_incoming_bytes_alert" {
  description = "Enable Event Hub incoming bytes alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_outgoing_bytes_alert" {
  description = "Enable Event Hub outgoing bytes alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_active_connections_alert" {
  description = "Enable Event Hub active connections alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_connections_opened_alert" {
  description = "Enable Event Hub connections opened alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_connections_closed_alert" {
  description = "Enable Event Hub connections closed alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_quota_exceeded_alert" {
  description = "Enable Event Hub quota exceeded alert"
  type        = bool
  default     = true
}

variable "enable_eventhub_size_alert" {
  description = "Enable Event Hub size alert (for individual Event Hubs)"
  type        = bool
  default     = true
}

variable "enable_eventhub_cpu_usage_alert" {
  description = "Enable Event Hub CPU usage alert (Premium tier only)"
  type        = bool
  default     = true
}

# Event Hub Alert Thresholds
variable "eventhub_incoming_requests_threshold" {
  description = "Threshold for Event Hub incoming requests alert (count)"
  type        = number
  default     = 10000

  validation {
    condition     = var.eventhub_incoming_requests_threshold > 0
    error_message = "Incoming requests threshold must be greater than 0."
  }
}

variable "eventhub_successful_requests_threshold" {
  description = "Threshold for Event Hub successful requests alert (minimum count)"
  type        = number
  default     = 100

  validation {
    condition     = var.eventhub_successful_requests_threshold > 0
    error_message = "Successful requests threshold must be greater than 0."
  }
}

variable "eventhub_server_errors_threshold" {
  description = "Threshold for Event Hub server errors alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventhub_server_errors_threshold > 0
    error_message = "Server errors threshold must be greater than 0."
  }
}

variable "eventhub_user_errors_threshold" {
  description = "Threshold for Event Hub user errors alert (count)"
  type        = number
  default     = 10

  validation {
    condition     = var.eventhub_user_errors_threshold > 0
    error_message = "User errors threshold must be greater than 0."
  }
}

variable "eventhub_throttled_requests_threshold" {
  description = "Threshold for Event Hub throttled requests alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventhub_throttled_requests_threshold > 0
    error_message = "Throttled requests threshold must be greater than 0."
  }
}

variable "eventhub_incoming_messages_threshold" {
  description = "Threshold for Event Hub incoming messages alert (count)"
  type        = number
  default     = 50000

  validation {
    condition     = var.eventhub_incoming_messages_threshold > 0
    error_message = "Incoming messages threshold must be greater than 0."
  }
}

variable "eventhub_outgoing_messages_threshold" {
  description = "Threshold for Event Hub outgoing messages alert (count)"
  type        = number
  default     = 50000

  validation {
    condition     = var.eventhub_outgoing_messages_threshold > 0
    error_message = "Outgoing messages threshold must be greater than 0."
  }
}

variable "eventhub_incoming_bytes_threshold" {
  description = "Threshold for Event Hub incoming bytes alert (bytes)"
  type        = number
  default     = 1073741824 # 1GB

  validation {
    condition     = var.eventhub_incoming_bytes_threshold > 0
    error_message = "Incoming bytes threshold must be greater than 0."
  }
}

variable "eventhub_outgoing_bytes_threshold" {
  description = "Threshold for Event Hub outgoing bytes alert (bytes)"
  type        = number
  default     = 1073741824 # 1GB

  validation {
    condition     = var.eventhub_outgoing_bytes_threshold > 0
    error_message = "Outgoing bytes threshold must be greater than 0."
  }
}

variable "eventhub_active_connections_threshold" {
  description = "Threshold for Event Hub active connections alert (count)"
  type        = number
  default     = 1000

  validation {
    condition     = var.eventhub_active_connections_threshold > 0
    error_message = "Active connections threshold must be greater than 0."
  }
}

variable "eventhub_connections_opened_threshold" {
  description = "Threshold for Event Hub connections opened alert (count)"
  type        = number
  default     = 5000

  validation {
    condition     = var.eventhub_connections_opened_threshold > 0
    error_message = "Connections opened threshold must be greater than 0."
  }
}

variable "eventhub_connections_closed_threshold" {
  description = "Threshold for Event Hub connections closed alert (count)"
  type        = number
  default     = 5000

  validation {
    condition     = var.eventhub_connections_closed_threshold > 0
    error_message = "Connections closed threshold must be greater than 0."
  }
}

variable "eventhub_quota_exceeded_threshold" {
  description = "Threshold for Event Hub quota exceeded alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventhub_quota_exceeded_threshold > 0
    error_message = "Quota exceeded threshold must be greater than 0."
  }
}

variable "eventhub_size_threshold" {
  description = "Threshold for Event Hub size alert (bytes)"
  type        = number
  default     = 85899345920 # 80GB (out of 100GB max for standard tier)

  validation {
    condition     = var.eventhub_size_threshold > 0
    error_message = "Event Hub size threshold must be greater than 0."
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
  description = "Subscription ID where the Event Hub namespace is located. If empty, uses the current subscription."
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID where the Log Analytics workspace is located. If empty, uses the current subscription."
  type        = string
  default     = ""
}
