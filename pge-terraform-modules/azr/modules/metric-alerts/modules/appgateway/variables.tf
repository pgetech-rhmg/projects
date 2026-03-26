variable "resource_group_name" {
  description = "The name of the resource group where the Application Gateways are located"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must not be empty."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = length(var.action_group_resource_group_name) > 0
    error_message = "Action group resource group name must not be empty."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string

  validation {
    condition     = length(var.action_group) > 0
    error_message = "Action group name must not be empty."
  }
}

variable "location" {
  description = "Azure region location for scheduled query rules"
  type        = string
  default     = "West US 2"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "application_gateway_names" {
  description = "List of Application Gateway names to monitor"
  type        = list(string)

  validation {
    condition     = length(var.application_gateway_names) > 0 && alltrue([for name in var.application_gateway_names : length(name) > 0])
    error_message = "At least one Application Gateway name must be provided and names cannot be empty strings."
  }
}

variable "appgw_compute_unit_threshold" {
  description = "Threshold for Application Gateway compute unit utilization (v2 SKU). Default: 7.5 CUs (75% of 10 CU average)"
  type        = number
  default     = 7.5

  validation {
    condition     = var.appgw_compute_unit_threshold > 0 && var.appgw_compute_unit_threshold <= 1000
    error_message = "Compute unit threshold must be between 0 and 1000."
  }
}

variable "appgw_capacity_unit_threshold" {
  description = "Threshold for Application Gateway capacity unit utilization (v2 SKU). Default: 75 CUs (75% of 100 CU max)"
  type        = number
  default     = 75

  validation {
    condition     = var.appgw_capacity_unit_threshold > 0 && var.appgw_capacity_unit_threshold <= 1000
    error_message = "Capacity unit threshold must be between 0 and 1000."
  }
}

variable "appgw_cpu_utilization_threshold" {
  description = "Threshold for CPU utilization percentage (v1 SKU). Default: 80%"
  type        = number
  default     = 80

  validation {
    condition     = var.appgw_cpu_utilization_threshold > 0 && var.appgw_cpu_utilization_threshold <= 100
    error_message = "CPU utilization threshold must be between 0 and 100."
  }
}

variable "appgw_unhealthy_host_threshold" {
  description = "Threshold for unhealthy backend host count. Default: 1 (alert on any unhealthy host)"
  type        = number
  default     = 1

  validation {
    condition     = var.appgw_unhealthy_host_threshold >= 0
    error_message = "Unhealthy host threshold must be greater than or equal to 0."
  }
}

variable "appgw_response_4xx_threshold" {
  description = "Threshold for 4xx client error responses in 15 minutes"
  type        = number
  default     = 50
}

variable "appgw_response_5xx_threshold" {
  description = "Threshold for 5xx server error responses in 15 minutes"
  type        = number
  default     = 10
}

variable "appgw_failed_requests_threshold" {
  description = "Threshold for failed request count in 15 minutes"
  type        = number
  default     = 100
}

variable "appgw_backend_response_time_threshold" {
  description = "Threshold for backend last byte response time in milliseconds"
  type        = number
  default     = 5000
}

variable "appgw_total_time_threshold" {
  description = "Threshold for Application Gateway total processing time in milliseconds"
  type        = number
  default     = 10000
}

variable "appgw_backend_connect_time_threshold" {
  description = "Threshold for backend connection time in milliseconds"
  type        = number
  default     = 1000
}

variable "appgw_throughput_threshold" {
  description = "Threshold for throughput in bytes per second. Default: 100 MBps (100000000 bytes/sec)"
  type        = number
  default     = 100000000
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

# Diagnostic Settings Variables
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Application Gateways"
  type        = bool
  default     = true
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace for diagnostic logs"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Name of the Event Hub for diagnostic logs"
  type        = string
  default     = ""
}

variable "eventhub_authorization_rule_name" {
  description = "Name of the Event Hub authorization rule"
  type        = string
  default     = "RootManageSharedAccessKey"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for diagnostic logs"
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
  description = "Subscription ID for Event Hub (leave empty to use current subscription)"
  type        = string
  default     = ""
}

variable "log_analytics_subscription_id" {
  description = "Subscription ID for Log Analytics workspace (leave empty to use current subscription)"
  type        = string
  default     = ""
}
