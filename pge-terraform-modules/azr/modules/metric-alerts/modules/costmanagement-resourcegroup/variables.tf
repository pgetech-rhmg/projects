# Azure Cost Management - Resource Group Level AMBA Variables
# This file contains variable definitions for resource group-level cost management monitoring alerts

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
variable "resource_group_names" {
  description = "List of resource group names to monitor for cost management. Example: ['prod-rg', 'dev-rg']"
  type        = list(string)
  default     = []
}

variable "subscription_id" {
  description = "Subscription ID where the resource groups are located"
  type        = string
  default     = ""
}

# Alert enable flags - Resource Group Level
variable "enable_resource_group_cost_alerts" {
  description = "Enable resource group-level cost monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_resource_group_trend_alerts" {
  description = "Enable resource group cost trend and anomaly alerts"
  type        = bool
  default     = true
}

variable "enable_resource_activity_alerts" {
  description = "Enable resource group activity and usage monitoring alerts"
  type        = bool
  default     = true
}

# Budget thresholds - Resource Group Level
variable "resource_group_monthly_cost_threshold" {
  description = "Monthly cost threshold for resource group budget alerts (USD)"
  type        = number
  default     = 2000

  validation {
    condition     = var.resource_group_monthly_cost_threshold > 0
    error_message = "The resource_group_monthly_cost_threshold must be greater than 0."
  }
}

variable "resource_group_daily_cost_threshold" {
  description = "Daily cost threshold for resource group spike alerts (USD)"
  type        = number
  default     = 100

  validation {
    condition     = var.resource_group_daily_cost_threshold > 0
    error_message = "The resource_group_daily_cost_threshold must be greater than 0."
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

# Resource Group specific thresholds
variable "resource_group_cost_increase_threshold_percent" {
  description = "Resource group cost increase threshold percentage to trigger alert"
  type        = number
  default     = 30

  validation {
    condition     = var.resource_group_cost_increase_threshold_percent > 0
    error_message = "The resource_group_cost_increase_threshold_percent must be greater than 0."
  }
}

variable "resource_creation_threshold" {
  description = "Number of resources created per day to trigger alert"
  type        = number
  default     = 10

  validation {
    condition     = var.resource_creation_threshold > 0
    error_message = "The resource_creation_threshold must be greater than 0."
  }
}

variable "resource_deletion_threshold" {
  description = "Number of resources deleted per day to trigger alert"
  type        = number
  default     = 5

  validation {
    condition     = var.resource_deletion_threshold > 0
    error_message = "The resource_deletion_threshold must be greater than 0."
  }
}

# Time-based variables
variable "evaluation_frequency_daily" {
  description = "Evaluation frequency for daily cost alerts"
  type        = string
  default     = "P1D"
}

variable "evaluation_frequency_hourly" {
  description = "Evaluation frequency for hourly cost alerts"
  type        = string
  default     = "PT1H"
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