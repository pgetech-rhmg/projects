# Event Grid Namespace AMBA Variables
# This file contains all variable definitions for Event Grid Namespace monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "Name of the resource group where Event Grid Namespace resources are located"
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

# Event Grid Namespace Names
variable "eventgrid_namespace_names" {
  description = "List of Event Grid namespace names to monitor"
  type        = list(string)
  default     = []
}

# Event Grid Namespace Alert Feature Flags
variable "enable_eventgrid_mqtt_published_alert" {
  description = "Enable Event Grid namespace MQTT published messages alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_mqtt_failed_published_alert" {
  description = "Enable Event Grid namespace MQTT failed published messages alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_mqtt_connections_alert" {
  description = "Enable Event Grid namespace MQTT connections alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_http_published_alert" {
  description = "Enable Event Grid namespace HTTP published events alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_http_failed_published_alert" {
  description = "Enable Event Grid namespace HTTP failed published events alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_delivery_attempts_failed_alert" {
  description = "Enable Event Grid namespace delivery attempts failed alert"
  type        = bool
  default     = true
}

variable "enable_eventgrid_delivery_attempts_succeeded_alert" {
  description = "Enable Event Grid namespace delivery attempts succeeded alert"
  type        = bool
  default     = false
}

# Event Grid Namespace Alert Thresholds
variable "eventgrid_mqtt_published_threshold" {
  description = "Threshold for Event Grid namespace MQTT published messages alert (count)"
  type        = number
  default     = 10000

  validation {
    condition     = var.eventgrid_mqtt_published_threshold > 0
    error_message = "MQTT published messages threshold must be greater than 0."
  }
}

variable "eventgrid_mqtt_failed_published_threshold" {
  description = "Threshold for Event Grid namespace MQTT failed published messages alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventgrid_mqtt_failed_published_threshold > 0
    error_message = "MQTT failed published messages threshold must be greater than 0."
  }
}

variable "eventgrid_mqtt_connections_threshold" {
  description = "Threshold for Event Grid namespace MQTT active connections alert (count)"
  type        = number
  default     = 1000

  validation {
    condition     = var.eventgrid_mqtt_connections_threshold > 0
    error_message = "MQTT connections threshold must be greater than 0."
  }
}

variable "eventgrid_http_published_threshold" {
  description = "Threshold for Event Grid namespace HTTP published events alert (count)"
  type        = number
  default     = 10000

  validation {
    condition     = var.eventgrid_http_published_threshold > 0
    error_message = "HTTP published events threshold must be greater than 0."
  }
}

variable "eventgrid_http_failed_published_threshold" {
  description = "Threshold for Event Grid namespace HTTP failed published events alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventgrid_http_failed_published_threshold > 0
    error_message = "HTTP failed published events threshold must be greater than 0."
  }
}

variable "eventgrid_delivery_attempts_failed_threshold" {
  description = "Threshold for Event Grid namespace delivery attempts failed alert (count)"
  type        = number
  default     = 1

  validation {
    condition     = var.eventgrid_delivery_attempts_failed_threshold > 0
    error_message = "Delivery attempts failed threshold must be greater than 0."
  }
}

variable "eventgrid_delivery_attempts_succeeded_threshold" {
  description = "Threshold for Event Grid namespace delivery attempts succeeded alert (count)"
  type        = number
  default     = 10000

  validation {
    condition     = var.eventgrid_delivery_attempts_succeeded_threshold > 0
    error_message = "Delivery attempts succeeded threshold must be greater than 0."
  }
}

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Event Grid Namespace resources"
  type        = bool
  default     = true
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace for diagnostic settings"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Name of the Event Hub for diagnostic settings"
  type        = string
  default     = ""
}

variable "eventhub_authorization_rule_name" {
  description = "Name of the Event Hub authorization rule for diagnostic settings"
  type        = string
  default     = "RootManageSharedAccessKey"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}

variable "log_analytics_resource_group_name" {
  description = "Resource group name where the Log Analytics workspace is located"
  type        = string
  default     = ""
}

variable "eventhub_resource_group_name" {
  description = "Resource group name where the Event Hub namespace is located"
  type        = string
  default     = ""
}

variable "eventhub_subscription_id" {
  description = "Subscription ID where the Event Hub namespace is located. If not provided, uses the current subscription."
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID where the Log Analytics workspace is located. If not provided, uses the current subscription."
  type        = string
  default     = ""
}
