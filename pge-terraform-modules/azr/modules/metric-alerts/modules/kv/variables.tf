variable "resource_group_name" {
  description = "The name of the resource group where the Key Vaults are located"
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

variable "key_vault_names" {
  description = "List of Key Vault names to monitor"
  type        = list(string)
  default     = []
}

# Availability and Latency Thresholds
variable "availability_threshold" {
  description = "Key Vault availability threshold percentage"
  type        = number
  default     = 99.9

  validation {
    condition     = var.availability_threshold > 0 && var.availability_threshold <= 100
    error_message = "Availability threshold must be between 0 and 100."
  }
}

variable "service_api_latency_threshold" {
  description = "Service API latency threshold in milliseconds"
  type        = number
  default     = 1000

  validation {
    condition     = var.service_api_latency_threshold > 0
    error_message = "Service API latency threshold must be greater than 0."
  }
}

# Request Rate Thresholds
variable "service_api_hit_threshold" {
  description = "Service API hit rate threshold"
  type        = number
  default     = 1000

  validation {
    condition     = var.service_api_hit_threshold > 0
    error_message = "Service API hit threshold must be greater than 0."
  }
}

variable "service_api_result_threshold" {
  description = "Service API result threshold for errors"
  type        = number
  default     = 10

  validation {
    condition     = var.service_api_result_threshold > 0
    error_message = "Service API result threshold must be greater than 0."
  }
}

# Saturation Thresholds
variable "saturation_shoebox_threshold" {
  description = "Saturation shoebox threshold percentage"
  type        = number
  default     = 75

  validation {
    condition     = var.saturation_shoebox_threshold > 0 && var.saturation_shoebox_threshold <= 100
    error_message = "Saturation shoebox threshold must be between 0 and 100."
  }
}

# Activity Log Alert Thresholds
variable "key_vault_access_policy_change_threshold" {
  description = "Threshold for Key Vault access policy changes"
  type        = number
  default     = 1
}

variable "key_vault_delete_threshold" {
  description = "Threshold for Key Vault deletion events"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to be applied to all metric alert resources"
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
