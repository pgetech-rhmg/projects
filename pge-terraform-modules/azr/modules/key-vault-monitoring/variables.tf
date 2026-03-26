/*
 * # Azure Key Vault Monitoring Variables
*/
#
# Filename    : modules/key-vault-monitoring/variables.tf
# Description : Input variables for the Key Vault Monitoring module
#

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Key Vaults are located"
  default     = ""
}

variable "action_group_resource_group_name" {
  type        = string
  description = "The name of the resource group where the action group is located"
}

variable "action_group" {
  type        = string
  description = "The name of the action group to be used in alerts"
  default     = ""
}

variable "key_vault_names" {
  type        = list(string)
  description = "List of Key Vault names to monitor"
  default     = []
}

# Availability and Latency Thresholds
variable "availability_threshold" {
  type        = number
  description = "Key Vault availability threshold percentage"
  default     = 99.9
}

variable "service_api_latency_threshold" {
  type        = number
  description = "Service API latency threshold in milliseconds"
  default     = 1000
}

# Request Rate Thresholds
variable "service_api_hit_threshold" {
  type        = number
  description = "Service API hit rate threshold"
  default     = 1000
}

variable "service_api_result_threshold" {
  type        = number
  description = "Service API result threshold for errors"
  default     = 10
}

# Saturation Thresholds
variable "saturation_shoebox_threshold" {
  type        = number
  description = "Saturation shoebox threshold percentage"
  default     = 75
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all metric alert resources"
  default     = {}
}

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  type        = bool
  description = "Enable diagnostic settings to send activity logs to Event Hub and security logs to Log Analytics"
  default     = true
}

variable "eventhub_namespace_name" {
  type        = string
  description = "Name of the Event Hub namespace for activity logs"
  default     = ""
}

variable "eventhub_name" {
  type        = string
  description = "Name of the Event Hub for activity logs"
  default     = ""
}

variable "eventhub_authorization_rule_name" {
  type        = string
  description = "Name of the Event Hub authorization rule"
  default     = "RootManageSharedAccessKey"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace for security logs"
  default     = ""
}

variable "log_analytics_resource_group_name" {
  type        = string
  description = "Resource group name of the Log Analytics workspace"
  default     = ""
}

variable "eventhub_resource_group_name" {
  type        = string
  description = "Resource group name of the Event Hub namespace"
  default     = ""
}

variable "eventhub_subscription_id" {
  type        = string
  description = "Subscription ID where the Event Hub namespace is located. If empty, uses the current subscription."
  default     = ""
}

variable "log_analytics_subscription_id" {
  type        = string
  description = "Subscription ID where the Log Analytics workspace is located. If empty, uses the current subscription."
  default     = ""
}