# Azure Automation Account AMBA Variables
# This file contains all variable definitions for Azure Automation Account monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Automation Accounts are located"
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
variable "automation_account_names" {
  description = "List of Automation Account names to monitor. Example: ['my-automation-prod', 'my-automation-dev']"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.automation_account_names : name != ""])
    error_message = "All Automation Account names in the list must be non-empty strings."
  }
}



variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Automation Account operations. Leave empty to disable all alerts. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid GUIDs in the format: 12345678-1234-1234-1234-123456789012."
  }
}

variable "automation_account_resource_ids" {
  description = "List of Automation Account resource IDs for scheduled query rules. Leave empty to disable resource-specific alerts. Example: ['/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/prod-rg/providers/Microsoft.Automation/automationAccounts/my-account-prod']"
  type        = list(string)
  default     = []
}

# Alert enable flags
variable "enable_automation_account_creation_alert" {
  description = "Enable Automation Account creation monitoring alert"
  type        = bool
  default     = true
}

variable "enable_automation_account_deletion_alert" {
  description = "Enable Automation Account deletion monitoring alert"
  type        = bool
  default     = true
}

variable "enable_runbook_operations_alert" {
  description = "Enable Runbook operations monitoring alert"
  type        = bool
  default     = true
}

variable "enable_hybrid_worker_alert" {
  description = "Enable Hybrid Worker monitoring alert"
  type        = bool
  default     = true
}

variable "enable_update_deployment_alert" {
  description = "Enable Update Deployment monitoring alert"
  type        = bool
  default     = true
}

variable "enable_webhook_alert" {
  description = "Enable Webhook operations monitoring alert"
  type        = bool
  default     = true
}

variable "enable_certificate_expiration_alert" {
  description = "Enable Certificate expiration monitoring alert"
  type        = bool
  default     = true
}

variable "window_duration_short" {
  description = "Short window duration for time-sensitive alerts"
  type        = string
  default     = "PT5M"
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
