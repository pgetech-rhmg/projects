# Service Bus AMBA Variables
# This file contains all variable definitions for Service Bus monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "Name of the resource group where Service Bus resources are located"
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
  description = "Name of the action group for alert notifications"
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
variable "servicebus_namespace_names" {
  description = "List of Service Bus Namespace names to monitor"
  type        = list(string)
  default     = []
}

# Alert enable flags
variable "enable_servicebus_incoming_requests_alert" {
  description = "Enable incoming requests monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_successful_requests_alert" {
  description = "Enable successful requests monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_server_errors_alert" {
  description = "Enable server errors monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_user_errors_alert" {
  description = "Enable user errors monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_throttled_requests_alert" {
  description = "Enable throttled requests monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_incoming_messages_alert" {
  description = "Enable incoming messages monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_outgoing_messages_alert" {
  description = "Enable outgoing messages monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_active_connections_alert" {
  description = "Enable active connections monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_connections_opened_alert" {
  description = "Enable connections opened monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_connections_closed_alert" {
  description = "Enable connections closed monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_size_alert" {
  description = "Enable namespace size monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_active_messages_alert" {
  description = "Enable active messages monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_dead_letter_messages_alert" {
  description = "Enable dead letter messages monitoring alert"
  type        = bool
  default     = true
}

variable "enable_servicebus_scheduled_messages_alert" {
  description = "Enable scheduled messages monitoring alert"
  type        = bool
  default     = true
}

# Alert thresholds
variable "servicebus_incoming_requests_threshold" {
  description = "Threshold for incoming requests alert (requests/min)"
  type        = number
  default     = 1000

  validation {
    condition     = var.servicebus_incoming_requests_threshold > 0
    error_message = "Incoming requests threshold must be greater than 0."
  }
}

variable "servicebus_successful_requests_threshold" {
  description = "Threshold for successful requests alert (requests/min)"
  type        = number
  default     = 10

  validation {
    condition     = var.servicebus_successful_requests_threshold >= 0
    error_message = "Successful requests threshold must be greater than or equal to 0."
  }
}

variable "servicebus_server_errors_threshold" {
  description = "Threshold for server errors alert (errors/min)"
  type        = number
  default     = 5

  validation {
    condition     = var.servicebus_server_errors_threshold >= 0
    error_message = "Server errors threshold must be greater than or equal to 0."
  }
}

variable "servicebus_user_errors_threshold" {
  description = "Threshold for user errors alert (errors/min)"
  type        = number
  default     = 10

  validation {
    condition     = var.servicebus_user_errors_threshold >= 0
    error_message = "User errors threshold must be greater than or equal to 0."
  }
}

variable "servicebus_throttled_requests_threshold" {
  description = "Threshold for throttled requests alert (requests/min)"
  type        = number
  default     = 5

  validation {
    condition     = var.servicebus_throttled_requests_threshold >= 0
    error_message = "Throttled requests threshold must be greater than or equal to 0."
  }
}

variable "servicebus_incoming_messages_threshold" {
  description = "Threshold for incoming messages alert (messages/min)"
  type        = number
  default     = 1000

  validation {
    condition     = var.servicebus_incoming_messages_threshold > 0
    error_message = "Incoming messages threshold must be greater than 0."
  }
}

variable "servicebus_outgoing_messages_threshold" {
  description = "Threshold for outgoing messages alert (messages/min)"
  type        = number
  default     = 1000

  validation {
    condition     = var.servicebus_outgoing_messages_threshold > 0
    error_message = "Outgoing messages threshold must be greater than 0."
  }
}

variable "servicebus_active_connections_threshold" {
  description = "Threshold for active connections alert (connections)"
  type        = number
  default     = 100

  validation {
    condition     = var.servicebus_active_connections_threshold > 0
    error_message = "Active connections threshold must be greater than 0."
  }
}

variable "servicebus_connections_opened_threshold" {
  description = "Threshold for connections opened alert (connections/min)"
  type        = number
  default     = 50

  validation {
    condition     = var.servicebus_connections_opened_threshold > 0
    error_message = "Connections opened threshold must be greater than 0."
  }
}

variable "servicebus_connections_closed_threshold" {
  description = "Threshold for connections closed alert (connections/min)"
  type        = number
  default     = 50

  validation {
    condition     = var.servicebus_connections_closed_threshold > 0
    error_message = "Connections closed threshold must be greater than 0."
  }
}

variable "servicebus_size_threshold" {
  description = "Threshold for namespace size alert (bytes)"
  type        = number
  default     = 85899345920 # 80GB

  validation {
    condition     = var.servicebus_size_threshold > 0
    error_message = "Size threshold must be greater than 0."
  }
}

variable "servicebus_active_messages_threshold" {
  description = "Threshold for active messages alert (message count)"
  type        = number
  default     = 1000

  validation {
    condition     = var.servicebus_active_messages_threshold > 0
    error_message = "Active messages threshold must be greater than 0."
  }
}

variable "servicebus_dead_letter_messages_threshold" {
  description = "Threshold for dead letter messages alert (message count)"
  type        = number
  default     = 10

  validation {
    condition     = var.servicebus_dead_letter_messages_threshold >= 0
    error_message = "Dead letter messages threshold must be greater than or equal to 0."
  }
}

variable "servicebus_scheduled_messages_threshold" {
  description = "Threshold for scheduled messages alert (message count)"
  type        = number
  default     = 100

  validation {
    condition     = var.servicebus_scheduled_messages_threshold > 0
    error_message = "Scheduled messages threshold must be greater than 0."
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
