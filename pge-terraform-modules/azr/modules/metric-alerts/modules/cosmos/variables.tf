variable "resource_group_name" {
  description = "The name of the resource group where the Cosmos DB accounts are located"
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
  default     = "pge-operations-actiongroup"

  validation {
    condition     = var.action_group != ""
    error_message = "The action_group name must not be empty."
  }
}

variable "cosmos_account_names" {
  description = "List of Cosmos DB account names to monitor. Leave empty to disable all alerts. Example: ['cosmos-account-prod', 'cosmos-account-dev']"
  type        = list(string)
  default     = []
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

# Cosmos DB Alert Thresholds
variable "cosmos_availability_threshold" {
  description = "Cosmos DB availability threshold percentage"
  type        = number
  default     = 99.9

  validation {
    condition     = var.cosmos_availability_threshold >= 0 && var.cosmos_availability_threshold <= 100
    error_message = "The cosmos_availability_threshold must be between 0 and 100."
  }
}

variable "cosmos_server_side_latency_threshold" {
  description = "Cosmos DB server side latency threshold in milliseconds"
  type        = number
  default     = 10

  validation {
    condition     = var.cosmos_server_side_latency_threshold > 0
    error_message = "The cosmos_server_side_latency_threshold must be greater than 0."
  }
}

variable "cosmos_ru_consumption_threshold" {
  description = "Cosmos DB total RU consumption threshold"
  type        = number
  default     = 10000

  validation {
    condition     = var.cosmos_ru_consumption_threshold > 0
    error_message = "The cosmos_ru_consumption_threshold must be greater than 0."
  }
}

variable "cosmos_normalized_ru_consumption_threshold" {
  description = "Cosmos DB normalized RU consumption threshold percentage (0-100)"
  type        = number
  default     = 80

  validation {
    condition     = var.cosmos_normalized_ru_consumption_threshold >= 0 && var.cosmos_normalized_ru_consumption_threshold <= 100
    error_message = "The cosmos_normalized_ru_consumption_threshold must be between 0 and 100."
  }
}

variable "cosmos_total_requests_threshold" {
  description = "Cosmos DB total requests threshold count"
  type        = number
  default     = 10000

  validation {
    condition     = var.cosmos_total_requests_threshold > 0
    error_message = "The cosmos_total_requests_threshold must be greater than 0."
  }
}

variable "cosmos_metadata_requests_threshold" {
  description = "Cosmos DB metadata requests threshold count"
  type        = number
  default     = 100

  validation {
    condition     = var.cosmos_metadata_requests_threshold > 0
    error_message = "The cosmos_metadata_requests_threshold must be greater than 0."
  }
}

variable "cosmos_data_usage_threshold" {
  description = "Cosmos DB data usage threshold in bytes"
  type        = number
  default     = 85899345920 # 80 GB in bytes

  validation {
    condition     = var.cosmos_data_usage_threshold > 0
    error_message = "The cosmos_data_usage_threshold must be greater than 0."
  }
}

variable "cosmos_index_usage_threshold" {
  description = "Cosmos DB index usage threshold in bytes"
  type        = number
  default     = 10737418240 # 10 GB in bytes

  validation {
    condition     = var.cosmos_index_usage_threshold > 0
    error_message = "The cosmos_index_usage_threshold must be greater than 0."
  }
}

variable "cosmos_provisioned_throughput_threshold" {
  description = "Cosmos DB provisioned throughput threshold in RU/s"
  type        = number
  default     = 40000

  validation {
    condition     = var.cosmos_provisioned_throughput_threshold > 0
    error_message = "The cosmos_provisioned_throughput_threshold must be greater than 0."
  }
}

# Feature flags for enabling/disabling specific alert categories
variable "enable_availability_alerts" {
  description = "Enable Cosmos DB availability alerts"
  type        = bool
  default     = true
}

variable "enable_performance_alerts" {
  description = "Enable Cosmos DB performance alerts (latency, RU consumption)"
  type        = bool
  default     = true
}

variable "enable_error_alerts" {
  description = "Enable Cosmos DB error alerts (throttling, failed requests)"
  type        = bool
  default     = true
}

variable "enable_capacity_alerts" {
  description = "Enable Cosmos DB capacity alerts (data usage, index usage)"
  type        = bool
  default     = true
}

variable "enable_activity_log_alerts" {
  description = "Enable Cosmos DB activity log alerts (deletions, configuration changes)"
  type        = bool
  default     = true
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
