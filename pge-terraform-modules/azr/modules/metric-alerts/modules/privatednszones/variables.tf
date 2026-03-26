# Private DNS Zones AMBA Variables
# This file contains all variable definitions for Private DNS Zones monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group containing DNS zones"
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

# Resource-specific variables
variable "dns_zone_names" {
  description = "List of Private DNS Zone names to monitor"
  type        = list(string)
  default     = []
}

