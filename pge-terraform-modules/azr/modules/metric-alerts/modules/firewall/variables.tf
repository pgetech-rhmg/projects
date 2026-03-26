variable "resource_group_name" {
  description = "The name of the resource group where the Azure Firewalls are located"
  type        = string
  default     = ""

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = length(var.action_group_resource_group_name) > 0 && length(var.action_group_resource_group_name) <= 90
    error_message = "Action group resource group name must be between 1 and 90 characters."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = length(var.action_group) > 0
    error_message = "Action group name cannot be empty."
  }
}

variable "location" {
  description = "Azure region location for scheduled query rules"
  type        = string
  default     = "West US 2"
}

variable "firewall_names" {
  description = "List of Azure Firewall names to monitor"
  type        = list(string)
  default     = []
}

variable "firewall_health_threshold" {
  description = "Threshold for firewall health state (100 = healthy, 0 = unhealthy). Alert when below this value"
  type        = number
  default     = 90

  validation {
    condition     = var.firewall_health_threshold >= 0 && var.firewall_health_threshold <= 100
    error_message = "Firewall health threshold must be between 0 and 100."
  }
}

variable "firewall_snat_port_utilization_threshold" {
  description = "Threshold for SNAT port utilization percentage. Alert when exceeding this value"
  type        = number
  default     = 95

  validation {
    condition     = var.firewall_snat_port_utilization_threshold > 0 && var.firewall_snat_port_utilization_threshold <= 100
    error_message = "SNAT port utilization threshold must be between 0 and 100."
  }
}

variable "firewall_throughput_threshold" {
  description = "Threshold for firewall throughput in bits/sec. Default 25 Gbps (25000000000)"
  type        = number
  default     = 25000000000

  validation {
    condition     = var.firewall_throughput_threshold > 0
    error_message = "Firewall throughput threshold must be greater than 0."
  }
}

variable "firewall_latency_threshold" {
  description = "Threshold for firewall latency probe in milliseconds"
  type        = number
  default     = 20

  validation {
    condition     = var.firewall_latency_threshold > 0
    error_message = "Firewall latency threshold must be greater than 0."
  }
}

variable "firewall_data_processed_threshold" {
  description = "Threshold for data processed by firewall in bytes per hour"
  type        = number
  default     = 1000000000000

  validation {
    condition     = var.firewall_data_processed_threshold > 0
    error_message = "Firewall data processed threshold must be greater than 0."
  }
}

variable "firewall_app_rule_hit_threshold" {
  description = "Threshold for application rule hit count per hour"
  type        = number
  default     = 100000

  validation {
    condition     = var.firewall_app_rule_hit_threshold > 0
    error_message = "Application rule hit threshold must be greater than 0."
  }
}

variable "firewall_net_rule_hit_threshold" {
  description = "Threshold for network rule hit count per hour"
  type        = number
  default     = 100000

  validation {
    condition     = var.firewall_net_rule_hit_threshold > 0
    error_message = "Network rule hit threshold must be greater than 0."
  }
}

variable "firewall_threat_intel_threshold" {
  description = "Threshold for threat intelligence hits. Alert when any malicious traffic is detected"
  type        = number
  default     = 0

  validation {
    condition     = var.firewall_threat_intel_threshold >= 0
    error_message = "Threat intelligence threshold must be greater than or equal to 0."
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
