# Azure Update Manager AMBA Variables
# This file contains all variable definitions for Azure Update Manager monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the resources are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != ""
    error_message = "Resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != ""
    error_message = "Action group resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "Action group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9 _-]{1,260}$", var.action_group))
    error_message = "Action group name must be 1-260 characters and contain only alphanumeric characters, spaces, underscores, and hyphens."
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
variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Update Manager operations. Example: ['12345678-1234-1234-1234-123456789012', '87654321-4321-4321-4321-210987654321']"
  type        = list(string)
  default     = []
}

variable "vm_resource_ids" {
  description = "List of Virtual Machine resource IDs to monitor for update compliance. Example: ['/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM1', '/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM2']"
  type        = list(string)
  default     = []
}

# Alert enable flags
variable "enable_update_deployment_failure_alert" {
  description = "Enable update deployment failure monitoring alert"
  type        = bool
  default     = true
}

variable "enable_update_compliance_alert" {
  description = "Enable update compliance monitoring alert"
  type        = bool
  default     = true
}

variable "enable_maintenance_window_alert" {
  description = "Enable maintenance window monitoring alert"
  type        = bool
  default     = true
}

variable "enable_patch_installation_failure_alert" {
  description = "Enable patch installation failure monitoring alert"
  type        = bool
  default     = true
}

variable "enable_update_assessment_failure_alert" {
  description = "Enable update assessment failure monitoring alert"
  type        = bool
  default     = true
}

variable "enable_critical_update_available_alert" {
  description = "Enable critical update available monitoring alert"
  type        = bool
  default     = true
}

# Alert thresholds
variable "update_deployment_failure_threshold" {
  description = "Threshold for update deployment failures"
  type        = number
  default     = 1

  validation {
    condition     = var.update_deployment_failure_threshold >= 0
    error_message = "Update deployment failure threshold must be greater than or equal to 0."
  }
}

variable "update_compliance_threshold" {
  description = "Threshold for update compliance percentage (alert when below this value)"
  type        = number
  default     = 90

  validation {
    condition     = var.update_compliance_threshold >= 0 && var.update_compliance_threshold <= 100
    error_message = "Update compliance threshold must be between 0 and 100."
  }
}

variable "patch_installation_failure_threshold" {
  description = "Threshold for patch installation failures"
  type        = number
  default     = 1

  validation {
    condition     = var.patch_installation_failure_threshold >= 0
    error_message = "Patch installation failure threshold must be greater than or equal to 0."
  }
}

variable "update_assessment_failure_threshold" {
  description = "Threshold for update assessment failures"
  type        = number
  default     = 1

  validation {
    condition     = var.update_assessment_failure_threshold >= 0
    error_message = "Update assessment failure threshold must be greater than or equal to 0."
  }
}

variable "critical_update_available_threshold" {
  description = "Threshold for critical updates available"
  type        = number
  default     = 1

  validation {
    condition     = var.critical_update_available_threshold >= 0
    error_message = "Critical update available threshold must be greater than or equal to 0."
  }
}

variable "maintenance_window_threshold" {
  description = "Threshold for maintenance window violations (minutes)"
  type        = number
  default     = 30

  validation {
    condition     = var.maintenance_window_threshold >= 0
    error_message = "Maintenance window threshold must be greater than or equal to 0."
  }
}