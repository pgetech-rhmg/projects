# Azure Application Insights AMBA Variables
# This file contains all variable definitions for Azure Application Insights monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Application Insights are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != ""
    error_message = "The resource_group_name must not be empty."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != ""
    error_message = "The action_group_resource_group_name must not be empty."
  }
}

variable "action_group" {
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "The action_group name must not be empty."
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
variable "application_insights_names" {
  description = "List of Application Insights names to monitor. Leave empty to disable Application Insights alerts. Example: ['appinsights-prod', 'appinsights-dev']"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.application_insights_names) > 0
    error_message = "At least one Application Insights name must be provided in application_insights_names."
  }

  validation {
    condition     = alltrue([for name in var.application_insights_names : name != ""])
    error_message = "All Application Insights names in the list must be non-empty strings."
  }
}

variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Application Insights operations. Leave empty to disable subscription-level alerts. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []
}

# Application Insights Alert Thresholds
variable "availability_threshold_percent" {
  description = "Threshold for availability alert (percentage)"
  type        = number
  default     = 95

  validation {
    condition     = var.availability_threshold_percent >= 0 && var.availability_threshold_percent <= 100
    error_message = "The availability_threshold_percent must be between 0 and 100."
  }
}

variable "response_time_threshold_ms" {
  description = "Threshold for average response time alert (milliseconds)"
  type        = number
  default     = 5000

  validation {
    condition     = var.response_time_threshold_ms > 0
    error_message = "The response_time_threshold_ms must be greater than 0."
  }
}

variable "exception_rate_threshold" {
  description = "Threshold for exception rate alert (count per period)"
  type        = number
  default     = 10

  validation {
    condition     = var.exception_rate_threshold >= 0
    error_message = "The exception_rate_threshold must be non-negative."
  }
}

variable "failed_requests_threshold" {
  description = "Threshold for failed requests alert (count per period)"
  type        = number
  default     = 20

  validation {
    condition     = var.failed_requests_threshold >= 0
    error_message = "The failed_requests_threshold must be non-negative."
  }
}

variable "dependency_duration_threshold_ms" {
  description = "Threshold for dependency duration alert (milliseconds)"
  type        = number
  default     = 10000

  validation {
    condition     = var.dependency_duration_threshold_ms > 0
    error_message = "The dependency_duration_threshold_ms must be greater than 0."
  }
}

variable "dependency_failure_rate_threshold" {
  description = "Threshold for dependency failure rate alert (count per period)"
  type        = number
  default     = 5

  validation {
    condition     = var.dependency_failure_rate_threshold >= 0
    error_message = "The dependency_failure_rate_threshold must be non-negative."
  }
}

variable "server_response_time_threshold_ms" {
  description = "Threshold for server response time alert (milliseconds)"
  type        = number
  default     = 3000

  validation {
    condition     = var.server_response_time_threshold_ms > 0
    error_message = "The server_response_time_threshold_ms must be greater than 0."
  }
}

variable "page_view_load_time_threshold_ms" {
  description = "Threshold for page view load time alert (milliseconds)"
  type        = number
  default     = 8000

  validation {
    condition     = var.page_view_load_time_threshold_ms > 0
    error_message = "The page_view_load_time_threshold_ms must be greater than 0."
  }
}

variable "request_rate_threshold" {
  description = "Threshold for request rate alert (requests per second)"
  type        = number
  default     = 100

  validation {
    condition     = var.request_rate_threshold >= 0
    error_message = "The request_rate_threshold must be non-negative."
  }
}

# Alert Frequency and Duration Settings
variable "evaluation_frequency_high" {
  description = "Evaluation frequency for high priority alerts"
  type        = string
  default     = "PT1M"
}

variable "evaluation_frequency_medium" {
  description = "Evaluation frequency for medium priority alerts"
  type        = string
  default     = "PT5M"
}

variable "evaluation_frequency_low" {
  description = "Evaluation frequency for low priority alerts"
  type        = string
  default     = "PT15M"
}

variable "window_duration_short" {
  description = "Window duration for short-term alerts"
  type        = string
  default     = "PT5M"
}

variable "window_duration_medium" {
  description = "Window duration for medium-term alerts"
  type        = string
  default     = "PT15M"
}

variable "window_duration_long" {
  description = "Window duration for long-term alerts"
  type        = string
  default     = "PT30M"
}

# Alert Enable/Disable Flags
variable "enable_availability_alerts" {
  description = "Enable availability monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_performance_alerts" {
  description = "Enable performance monitoring alerts (response time, dependency duration)"
  type        = bool
  default     = true
}

variable "enable_error_alerts" {
  description = "Enable error monitoring alerts (exceptions, failed requests)"
  type        = bool
  default     = true
}

variable "enable_usage_alerts" {
  description = "Enable usage monitoring alerts (request rate, page views)"
  type        = bool
  default     = true
}

variable "enable_dependency_alerts" {
  description = "Enable dependency monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_activity_log_alerts" {
  description = "Enable activity log alerts for Application Insights operations"
  type        = bool
  default     = true
}

# Diagnostic Settings Variables
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
