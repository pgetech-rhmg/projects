# Variables for Azure Connection Monitor AMBA Alerts Module

variable "resource_group_name" {
  description = "Resource group name where Connection Monitors are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != ""
    error_message = "The resource_group_name must not be empty."
  }
}

variable "action_group_resource_group_name" {
  description = "Resource group name where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != ""
    error_message = "The action_group_resource_group_name must not be empty."
  }
}

variable "action_group" {
  description = "Name of the action group to use for alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "The action_group name must not be empty."
  }
}

variable "connection_monitor_ids" {
  description = <<-EOT
    List of Connection Monitor resource IDs to create alerts for.
    Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkWatchers/{networkWatcherName}/connectionMonitors/{connectionMonitorName}
    
    Example:
    [
      "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus2/connectionMonitors/vpn-monitor",
      "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_westus2/connectionMonitors/expressroute-monitor"
    ]
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.connection_monitor_ids) > 0
    error_message = "At least one Connection Monitor resource ID must be provided."
  }

  validation {
    condition     = alltrue([for id in var.connection_monitor_ids : can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/networkWatchers/[^/]+/connectionMonitors/[^/]+$", id))])
    error_message = "All Connection Monitor IDs must be valid resource IDs with the format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/networkWatchers/{nw}/connectionMonitors/{cm}."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West US 2"
}

# Alert Threshold Variables
variable "checks_failed_threshold" {
  description = "Threshold for percentage of failed connectivity checks"
  type        = number
  default     = 10

  validation {
    condition     = var.checks_failed_threshold >= 0 && var.checks_failed_threshold <= 100
    error_message = "The checks_failed_threshold must be between 0 and 100."
  }
}

variable "latency_threshold_ms" {
  description = "Threshold for round-trip time in milliseconds"
  type        = number
  default     = 100

  validation {
    condition     = var.latency_threshold_ms > 0
    error_message = "The latency_threshold_ms must be greater than 0."
  }
}

variable "checks_failed_critical_threshold" {
  description = "Critical threshold for percentage of failed connectivity checks"
  type        = number
  default     = 50

  validation {
    condition     = var.checks_failed_critical_threshold >= 0 && var.checks_failed_critical_threshold <= 100
    error_message = "The checks_failed_critical_threshold must be between 0 and 100."
  }
}

variable "latency_critical_threshold_ms" {
  description = "Critical threshold for round-trip time in milliseconds"
  type        = number
  default     = 500

  validation {
    condition     = var.latency_critical_threshold_ms > 0
    error_message = "The latency_critical_threshold_ms must be greater than 0."
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
