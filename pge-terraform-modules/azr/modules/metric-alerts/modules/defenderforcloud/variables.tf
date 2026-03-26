# Azure Security Center (Microsoft Defender for Cloud) AMBA Variables
# This file contains all variable definitions for Azure Security Center monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where Security Center alerts will be created"
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

# Subscription and scope variables
variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Security Center alerts. Leave empty to disable subscription-level alerts. Example: ['sub-12345', 'sub-67890']"
  type        = list(string)
  default     = []
}

# Alert enablement flags (Activity Log based only)

variable "enable_policy_alerts" {
  description = "Enable security policy and recommendation alerts"
  type        = bool
  default     = true
}

variable "enable_defender_plan_alerts" {
  description = "Enable Microsoft Defender plan status alerts"
  type        = bool
  default     = true
}

# Microsoft Defender Plans
variable "monitor_defender_for_servers" {
  description = "Monitor Microsoft Defender for Servers plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_app_service" {
  description = "Monitor Microsoft Defender for App Service plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_storage" {
  description = "Monitor Microsoft Defender for Storage plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_sql" {
  description = "Monitor Microsoft Defender for SQL plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_containers" {
  description = "Monitor Microsoft Defender for Containers plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_key_vault" {
  description = "Monitor Microsoft Defender for Key Vault plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_resource_manager" {
  description = "Monitor Microsoft Defender for Resource Manager plan status"
  type        = bool
  default     = true
}

variable "monitor_defender_for_dns" {
  description = "Monitor Microsoft Defender for DNS plan status"
  type        = bool
  default     = true
}