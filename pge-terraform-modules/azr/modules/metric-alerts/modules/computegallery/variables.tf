# Azure Compute Gallery AMBA Variables
# This file contains all variable definitions for Azure Compute Gallery monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Compute Galleries are located"
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

# Resource-specific variables
variable "subscription_ids" {
  description = "List of subscription IDs to monitor for Compute Gallery operations. Required to create alerts. Example: ['12345678-1234-1234-1234-123456789012']"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid GUIDs in the format: 12345678-1234-1234-1234-123456789012."
  }
}

# Alert enable flags
variable "enable_gallery_creation_alert" {
  description = "Enable Compute Gallery creation monitoring alert"
  type        = bool
  default     = true
}

variable "enable_gallery_deletion_alert" {
  description = "Enable Compute Gallery deletion monitoring alert"
  type        = bool
  default     = true
}

variable "enable_gallery_modification_alert" {
  description = "Enable Compute Gallery modification monitoring alert"
  type        = bool
  default     = true
}

variable "enable_image_definition_alert" {
  description = "Enable Image Definition monitoring alert"
  type        = bool
  default     = true
}

variable "enable_image_version_alert" {
  description = "Enable Image Version monitoring alert"
  type        = bool
  default     = true
}

variable "enable_replication_failure_alert" {
  description = "Enable replication failure monitoring alert"
  type        = bool
  default     = true
}

variable "enable_sharing_profile_alert" {
  description = "Enable sharing profile changes monitoring alert"
  type        = bool
  default     = true
}

variable "enable_access_control_alert" {
  description = "Enable access control changes monitoring alert"
  type        = bool
  default     = true
}

# Alert thresholds
variable "replication_failure_threshold" {
  description = "Threshold for replication failures (number of failures)"
  type        = number
  default     = 1
}

variable "image_version_creation_threshold" {
  description = "Threshold for image version creation rate (versions per hour)"
  type        = number
  default     = 10
}

variable "image_definition_threshold" {
  description = "Threshold for image definition operations"
  type        = number
  default     = 5
}

variable "gallery_access_threshold" {
  description = "Threshold for gallery access control changes"
  type        = number
  default     = 1
}

# Monitoring settings
variable "evaluation_frequency_standard" {
  description = "Standard evaluation frequency for most alerts"
  type        = string
  default     = "PT15M"
}

variable "evaluation_frequency_critical" {
  description = "Critical evaluation frequency for high-priority alerts"
  type        = string
  default     = "PT5M"
}

variable "window_duration_standard" {
  description = "Standard window duration for most alerts"
  type        = string
  default     = "PT1H"
}

variable "window_duration_critical" {
  description = "Critical window duration for high-priority alerts"
  type        = string
  default     = "PT15M"
}