# Azure Monitor AMBA Variables
# This file contains all variable definitions for Azure Monitor resources monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where Azure Monitor resources are located"
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
  description = "The name of the action group to be used in alerts"
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

# Subscription and scope variables
variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Azure Monitor alerts. Example: ['sub-12345', 'sub-67890']"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_names" {
  description = "List of Log Analytics workspace names to monitor. Leave empty to disable workspace-specific alerts. Example: ['workspace-prod', 'workspace-dev']"
  type        = list(string)
  default     = []
}

variable "application_insights_names" {
  description = "List of Application Insights resource names to monitor. Leave empty to disable App Insights alerts. Example: ['appinsights-web', 'appinsights-api']"
  type        = list(string)
  default     = []
}

variable "data_collection_rule_names" {
  description = "List of Data Collection Rule names to monitor. Leave empty to disable DCR alerts. Example: ['dcr-vm-insights', 'dcr-container-insights']"
  type        = list(string)
  default     = []
}

# Alert enablement flags
variable "enable_workspace_alerts" {
  description = "Enable Log Analytics workspace related alerts"
  type        = bool
  default     = true
}

variable "enable_application_insights_alerts" {
  description = "Enable Application Insights related alerts"
  type        = bool
  default     = true
}

variable "enable_data_collection_alerts" {
  description = "Enable Data Collection Rule alerts"
  type        = bool
  default     = true
}

variable "enable_monitor_service_alerts" {
  description = "Enable Azure Monitor service level alerts"
  type        = bool
  default     = true
}

variable "enable_diagnostic_settings_alerts" {
  description = "Enable diagnostic settings related alerts"
  type        = bool
  default     = true
}

# Log Analytics Workspace thresholds
variable "workspace_data_ingestion_threshold_gb" {
  description = "Threshold for daily data ingestion in GB for Log Analytics workspace"
  type        = number
  default     = 100

  validation {
    condition     = var.workspace_data_ingestion_threshold_gb > 0
    error_message = "Workspace data ingestion threshold must be greater than 0."
  }
}

variable "workspace_data_ingestion_critical_threshold_gb" {
  description = "Critical threshold for daily data ingestion in GB for Log Analytics workspace"
  type        = number
  default     = 200

  validation {
    condition     = var.workspace_data_ingestion_critical_threshold_gb > 0
    error_message = "Workspace data ingestion critical threshold must be greater than 0."
  }
}

variable "workspace_data_retention_days" {
  description = "Expected data retention days for Log Analytics workspace"
  type        = number
  default     = 30
}

variable "workspace_query_timeout_threshold_minutes" {
  description = "Threshold for workspace query timeout in minutes"
  type        = number
  default     = 5
}

# Application Insights thresholds
variable "app_insights_availability_threshold_percent" {
  description = "Threshold for Application Insights availability percentage"
  type        = number
  default     = 95

  validation {
    condition     = var.app_insights_availability_threshold_percent > 0 && var.app_insights_availability_threshold_percent <= 100
    error_message = "Application Insights availability threshold must be between 0 and 100."
  }
}

variable "app_insights_response_time_threshold_ms" {
  description = "Threshold for Application Insights response time in milliseconds"
  type        = number
  default     = 5000

  validation {
    condition     = var.app_insights_response_time_threshold_ms > 0
    error_message = "Application Insights response time threshold must be greater than 0."
  }
}

variable "app_insights_failed_requests_threshold" {
  description = "Threshold for Application Insights failed requests count"
  type        = number
  default     = 10

  validation {
    condition     = var.app_insights_failed_requests_threshold > 0
    error_message = "Application Insights failed requests threshold must be greater than 0."
  }
}

variable "app_insights_exception_rate_threshold" {
  description = "Threshold for Application Insights exception rate"
  type        = number
  default     = 5

  validation {
    condition     = var.app_insights_exception_rate_threshold > 0
    error_message = "Application Insights exception rate threshold must be greater than 0."
  }
}

# Data Collection Rules thresholds
variable "dcr_collection_failure_threshold_percent" {
  description = "Threshold for data collection rule failure percentage"
  type        = number
  default     = 5
}

variable "dcr_data_latency_threshold_minutes" {
  description = "Threshold for data collection latency in minutes"
  type        = number
  default     = 15
}

# Time-based configuration
variable "evaluation_frequency_high" {
  description = "High frequency evaluation for critical alerts (PT1M, PT5M, PT15M, PT30M, PT1H)"
  type        = string
  default     = "PT5M"
}

variable "evaluation_frequency_medium" {
  description = "Medium frequency evaluation for standard alerts (PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D)"
  type        = string
  default     = "PT15M"
}

variable "evaluation_frequency_low" {
  description = "Low frequency evaluation for informational alerts (PT30M, PT1H, PT6H, PT12H, P1D)"
  type        = string
  default     = "PT1H"
}

variable "window_duration_short" {
  description = "Short window duration for time-sensitive alerts (PT1M, PT5M, PT15M, PT30M)"
  type        = string
  default     = "PT5M"
}

variable "window_duration_medium" {
  description = "Medium window duration for standard alerts (PT5M, PT15M, PT30M, PT1H, PT6H, PT12H)"
  type        = string
  default     = "PT15M"
}

variable "window_duration_long" {
  description = "Long window duration for trend analysis (PT30M, PT1H, PT6H, PT12H, P1D)"
  type        = string
  default     = "PT1H"
}
