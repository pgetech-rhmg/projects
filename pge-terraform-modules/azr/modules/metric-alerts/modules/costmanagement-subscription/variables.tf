# Azure Cost Management - Subscription Level AMBA Variables
# This file contains variable definitions for subscription-level cost management monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where cost management alerts will be created"
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
  description = "The name of the action group to be used in alerts"
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

# Contact configuration
variable "contact_emails" {
  description = "List of email addresses to notify for cost management alerts"
  type        = list(string)
  default = [
    "finance@pge.com",
    "operations@pge.com"
  ]
}

# Resource-specific variables
variable "subscription_ids" {
  description = "List of subscription IDs to monitor for cost management. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []
}

# Alert enable flags - Subscription Level
variable "enable_subscription_cost_alerts" {
  description = "Enable subscription-level cost monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_cost_increase_alerts" {
  description = "Enable cost increase and trend monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_export_alerts" {
  description = "Enable cost export and configuration monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_service_cost_alerts" {
  description = "Enable service-specific cost monitoring alerts (Compute, Storage, Database, Networking)"
  type        = bool
  default     = true
}

# Budget thresholds - Subscription Level
variable "subscription_monthly_cost_threshold" {
  description = "Monthly cost threshold for subscription budget alerts (USD)"
  type        = number
  default     = 10000

  validation {
    condition     = var.subscription_monthly_cost_threshold > 0
    error_message = "The subscription_monthly_cost_threshold must be greater than 0."
  }
}

variable "subscription_daily_cost_threshold" {
  description = "Daily cost threshold for subscription spike alerts (USD)"
  type        = number
  default     = 500

  validation {
    condition     = var.subscription_daily_cost_threshold > 0
    error_message = "The subscription_daily_cost_threshold must be greater than 0."
  }
}

# Budget alert percentage thresholds
variable "budget_alert_percentage_first" {
  description = "First budget alert threshold percentage (0-100)"
  type        = number
  default     = 75

  validation {
    condition     = var.budget_alert_percentage_first >= 0 && var.budget_alert_percentage_first <= 200
    error_message = "The budget_alert_percentage_first must be between 0 and 200."
  }
}

variable "budget_alert_percentage_second" {
  description = "Second budget alert threshold percentage (0-100)"
  type        = number
  default     = 90

  validation {
    condition     = var.budget_alert_percentage_second >= 0 && var.budget_alert_percentage_second <= 200
    error_message = "The budget_alert_percentage_second must be between 0 and 200."
  }
}

variable "budget_alert_percentage_critical" {
  description = "Critical budget alert threshold percentage (0-100)"
  type        = number
  default     = 100

  validation {
    condition     = var.budget_alert_percentage_critical >= 0 && var.budget_alert_percentage_critical <= 200
    error_message = "The budget_alert_percentage_critical must be between 0 and 200."
  }
}

# Service-specific cost thresholds
variable "compute_cost_threshold" {
  description = "Monthly cost threshold for compute services (USD)"
  type        = number
  default     = 3000

  validation {
    condition     = var.compute_cost_threshold > 0
    error_message = "The compute_cost_threshold must be greater than 0."
  }
}

variable "storage_cost_threshold" {
  description = "Monthly cost threshold for storage services (USD)"
  type        = number
  default     = 1500

  validation {
    condition     = var.storage_cost_threshold > 0
    error_message = "The storage_cost_threshold must be greater than 0."
  }
}

variable "database_cost_threshold" {
  description = "Monthly cost threshold for database services (USD)"
  type        = number
  default     = 2000

  validation {
    condition     = var.database_cost_threshold > 0
    error_message = "The database_cost_threshold must be greater than 0."
  }
}

variable "networking_cost_threshold" {
  description = "Monthly cost threshold for networking services (USD)"
  type        = number
  default     = 1000

  validation {
    condition     = var.networking_cost_threshold > 0
    error_message = "The networking_cost_threshold must be greater than 0."
  }
}

# Cost trend thresholds
variable "weekly_cost_increase_threshold_percent" {
  description = "Weekly cost increase threshold percentage to trigger alert"
  type        = number
  default     = 25

  validation {
    condition     = var.weekly_cost_increase_threshold_percent > 0
    error_message = "The weekly_cost_increase_threshold_percent must be greater than 0."
  }
}

# Time-based variables
variable "evaluation_frequency_daily" {
  description = "Evaluation frequency for daily cost alerts"
  type        = string
  default     = "P1D"
}

variable "window_duration_daily" {
  description = "Window duration for daily cost alerts"
  type        = string
  default     = "P1D"
}

variable "window_duration_weekly" {
  description = "Window duration for weekly cost alerts"
  type        = string
  default     = "P7D"
}