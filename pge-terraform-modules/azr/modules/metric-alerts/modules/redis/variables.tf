# Redis Cache AMBA Variables
# This file contains all variable definitions for Redis Cache monitoring alerts

# Common variables
variable "resource_group_name" {
  description = "The name of the resource group where the Redis Cache instances are located"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9._\\-()]+$", var.resource_group_name)) || var.resource_group_name == ""
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
  description = "Name of the action group for alert notifications"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_\\-]+$", var.action_group)) || var.action_group == ""
    error_message = "Action group name must contain only alphanumeric characters, underscores, and hyphens."
  }
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
variable "redis_cache_names" {
  description = "List of Redis Cache names to monitor"
  type        = list(string)
  default     = []
}

# Alert enable flags
variable "enable_redis_cpu_alert" {
  description = "Enable CPU usage monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_memory_alert" {
  description = "Enable memory usage monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_server_load_alert" {
  description = "Enable server load monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_connected_clients_alert" {
  description = "Enable connected clients monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_cache_miss_rate_alert" {
  description = "Enable cache miss rate monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_evicted_keys_alert" {
  description = "Enable evicted keys monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_expired_keys_alert" {
  description = "Enable expired keys monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_total_keys_alert" {
  description = "Enable total keys monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_operations_per_second_alert" {
  description = "Enable operations per second monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_cache_read_bandwidth_alert" {
  description = "Enable cache read bandwidth monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_cache_write_bandwidth_alert" {
  description = "Enable cache write bandwidth monitoring alert"
  type        = bool
  default     = true
}

variable "enable_redis_total_commands_processed_alert" {
  description = "Enable total commands processed monitoring alert"
  type        = bool
  default     = true
}

# Alert thresholds
variable "redis_cpu_threshold" {
  description = "Threshold for CPU usage alert (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.redis_cpu_threshold > 0 && var.redis_cpu_threshold <= 100
    error_message = "CPU threshold must be between 0 and 100."
  }
}

variable "redis_memory_threshold" {
  description = "Threshold for memory usage alert (percentage)"
  type        = number
  default     = 90

  validation {
    condition     = var.redis_memory_threshold > 0 && var.redis_memory_threshold <= 100
    error_message = "Memory threshold must be between 0 and 100."
  }
}

variable "redis_server_load_threshold" {
  description = "Threshold for server load alert (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.redis_server_load_threshold > 0 && var.redis_server_load_threshold <= 100
    error_message = "Server load threshold must be between 0 and 100."
  }
}

variable "redis_connected_clients_threshold" {
  description = "Threshold for connected clients alert (count)"
  type        = number
  default     = 250

  validation {
    condition     = var.redis_connected_clients_threshold > 0
    error_message = "Connected clients threshold must be greater than 0."
  }
}

variable "redis_cache_miss_rate_threshold" {
  description = "Threshold for cache miss rate alert (percentage)"
  type        = number
  default     = 20

  validation {
    condition     = var.redis_cache_miss_rate_threshold >= 0 && var.redis_cache_miss_rate_threshold <= 100
    error_message = "Cache miss rate threshold must be between 0 and 100."
  }
}

variable "redis_evicted_keys_threshold" {
  description = "Threshold for evicted keys alert (count per minute)"
  type        = number
  default     = 10

  validation {
    condition     = var.redis_evicted_keys_threshold >= 0
    error_message = "Evicted keys threshold must be greater than or equal to 0."
  }
}

variable "redis_expired_keys_threshold" {
  description = "Threshold for expired keys alert (count per minute)"
  type        = number
  default     = 10

  validation {
    condition     = var.redis_expired_keys_threshold >= 0
    error_message = "Expired keys threshold must be greater than or equal to 0."
  }
}

variable "redis_total_keys_threshold" {
  description = "Threshold for total keys alert (count)"
  type        = number
  default     = 1000000

  validation {
    condition     = var.redis_total_keys_threshold > 0
    error_message = "Total keys threshold must be greater than 0."
  }
}

variable "redis_operations_per_second_threshold" {
  description = "Threshold for operations per second alert (ops/sec)"
  type        = number
  default     = 1000

  validation {
    condition     = var.redis_operations_per_second_threshold > 0
    error_message = "Operations per second threshold must be greater than 0."
  }
}

variable "redis_cache_read_bandwidth_threshold" {
  description = "Threshold for cache read bandwidth alert (bytes/sec)"
  type        = number
  default     = 104857600 # 100MB/s

  validation {
    condition     = var.redis_cache_read_bandwidth_threshold > 0
    error_message = "Cache read bandwidth threshold must be greater than 0."
  }
}

variable "redis_cache_write_bandwidth_threshold" {
  description = "Threshold for cache write bandwidth alert (bytes/sec)"
  type        = number
  default     = 104857600 # 100MB/s

  validation {
    condition     = var.redis_cache_write_bandwidth_threshold > 0
    error_message = "Cache write bandwidth threshold must be greater than 0."
  }
}

variable "redis_total_commands_processed_threshold" {
  description = "Threshold for total commands processed alert (commands/sec)"
  type        = number
  default     = 1000

  validation {
    condition     = var.redis_total_commands_processed_threshold > 0
    error_message = "Total commands processed threshold must be greater than 0."
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
  description = "Subscription ID where the Event Hub namespace is located (leave empty to use current subscription)"
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID where the Log Analytics workspace is located (leave empty to use current subscription)"
  type        = string
  default     = ""
}
