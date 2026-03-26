variable "resource_group_name" {
  description = "The name of the resource group where the virtual machines are located"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_group_name != ""
    error_message = "Resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group_resource_group_name" {
  description = "The name of the resource group where the action group is located"
  type        = string

  validation {
    condition     = var.action_group_resource_group_name != ""
    error_message = "Action group resource group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.action_group_resource_group_name))
    error_message = "Action group resource group name must be 1-90 characters and contain only alphanumeric characters, periods, underscores, hyphens, and parentheses."
  }
}

variable "action_group" {
  description = "The name of the action group to be used in alerts"
  type        = string
  default     = ""

  validation {
    condition     = var.action_group != ""
    error_message = "Action group name must be provided and cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9 _-]{1,260}$", var.action_group))
    error_message = "Action group name must be 1-260 characters and contain only alphanumeric characters, spaces, underscores, and hyphens."
  }
}

variable "virtual_machine_names" {
  description = "List of virtual machine names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.virtual_machine_names : can(regex("^[a-zA-Z0-9-]{1,64}$", name))
    ])
    error_message = "Virtual machine names must be 1-64 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "cpu_percentage_threshold" {
  description = "CPU percentage threshold for warning alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_percentage_threshold >= 0 && var.cpu_percentage_threshold <= 100
    error_message = "CPU percentage threshold must be between 0 and 100."
  }
}

variable "cpu_percentage_critical_threshold" {
  description = "CPU percentage threshold for critical alerts"
  type        = number
  default     = 90

  validation {
    condition     = var.cpu_percentage_critical_threshold >= 0 && var.cpu_percentage_critical_threshold <= 100
    error_message = "CPU percentage critical threshold must be between 0 and 100."
  }
}

variable "memory_percentage_threshold" {
  description = "Available memory threshold (percentage of total memory)"
  type        = number
  default     = 20

  validation {
    condition     = var.memory_percentage_threshold >= 0 && var.memory_percentage_threshold <= 100
    error_message = "Memory percentage threshold must be between 0 and 100."
  }
}

variable "memory_percentage_critical_threshold" {
  description = "Available memory critical threshold (percentage of total memory)"
  type        = number
  default     = 10

  validation {
    condition     = var.memory_percentage_critical_threshold >= 0 && var.memory_percentage_critical_threshold <= 100
    error_message = "Memory percentage critical threshold must be between 0 and 100."
  }
}

variable "disk_iops_threshold" {
  description = "Disk IOPS threshold for read/write operations alerts"
  type        = number
  default     = 500

  validation {
    condition     = var.disk_iops_threshold >= 0
    error_message = "Disk IOPS threshold must be greater than or equal to 0."
  }
}

variable "disk_queue_depth_threshold" {
  description = "Disk queue depth threshold"
  type        = number
  default     = 32

  validation {
    condition     = var.disk_queue_depth_threshold >= 0
    error_message = "Disk queue depth threshold must be greater than or equal to 0."
  }
}

variable "network_in_threshold" {
  description = "Network bytes in threshold (bytes/sec)"
  type        = number
  default     = 104857600 # 100MB/s

  validation {
    condition     = var.network_in_threshold >= 0
    error_message = "Network in threshold must be greater than or equal to 0."
  }
}

variable "network_out_threshold" {
  description = "Network bytes out threshold (bytes/sec)"
  type        = number
  default     = 104857600 # 100MB/s

  validation {
    condition     = var.network_out_threshold >= 0
    error_message = "Network out threshold must be greater than or equal to 0."
  }
}

variable "vm_heartbeat_threshold" {
  description = "VM heartbeat threshold in minutes"
  type        = number
  default     = 5

  validation {
    condition     = var.vm_heartbeat_threshold >= 0
    error_message = "VM heartbeat threshold must be greater than or equal to 0."
  }
}

variable "data_disk_read_bytes_threshold" {
  description = "Data disk read bytes/sec threshold"
  type        = number
  default     = 52428800 # 50MB/s

  validation {
    condition     = var.data_disk_read_bytes_threshold >= 0
    error_message = "Data disk read bytes threshold must be greater than or equal to 0."
  }
}

variable "data_disk_write_bytes_threshold" {
  description = "Data disk write bytes/sec threshold"
  type        = number
  default     = 52428800 # 50MB/s

  validation {
    condition     = var.data_disk_write_bytes_threshold >= 0
    error_message = "Data disk write bytes threshold must be greater than or equal to 0."
  }
}

variable "premium_disk_cache_miss_threshold" {
  description = "Premium disk cache miss percentage threshold"
  type        = number
  default     = 20

  validation {
    condition     = var.premium_disk_cache_miss_threshold >= 0 && var.premium_disk_cache_miss_threshold <= 100
    error_message = "Premium disk cache miss threshold must be between 0 and 100."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
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
  description = "Enable diagnostic settings for Virtual Machines"
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

