variable "resource_group_name" {
  description = "The name of the resource group where the App Service Environments are located"
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

variable "ase_names" {
  description = "List of App Service Environment names to monitor"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.ase_names) > 0
    error_message = "At least one App Service Environment name must be provided in ase_names."
  }

  validation {
    condition     = alltrue([for name in var.ase_names : name != ""])
    error_message = "All App Service Environment names in the list must be non-empty strings."
  }
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    "AppId"              = "123456"
    "CRIS"               = "1"
    "Compliance"         = "None"
    "DataClassification" = "internal"
    "Env"                = "Dev"
    "Notify"             = "abc@pge.com"
    "Owner"              = "abc@pge.com"
    "order"              = "123456"
  }
}

# ASE CPU Utilization Thresholds
variable "ase_cpu_percentage_threshold" {
  description = "ASE CPU percentage threshold for alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.ase_cpu_percentage_threshold >= 0 && var.ase_cpu_percentage_threshold <= 100
    error_message = "The ase_cpu_percentage_threshold must be between 0 and 100."
  }
}

# ASE Memory Utilization Thresholds
variable "ase_memory_percentage_threshold" {
  description = "ASE memory percentage threshold for alerts"
  type        = number
  default     = 80

  validation {
    condition     = var.ase_memory_percentage_threshold >= 0 && var.ase_memory_percentage_threshold <= 100
    error_message = "The ase_memory_percentage_threshold must be between 0 and 100."
  }
}

# ASE Large App Service Plan Instance Thresholds
variable "ase_large_app_service_plan_instances_threshold" {
  description = "ASE large App Service plan instances threshold for alerts"
  type        = number
  default     = 8

  validation {
    condition     = var.ase_large_app_service_plan_instances_threshold >= 0
    error_message = "The ase_large_app_service_plan_instances_threshold must be non-negative."
  }
}

# ASE Medium App Service Plan Instance Thresholds
variable "ase_medium_app_service_plan_instances_threshold" {
  description = "ASE medium App Service plan instances threshold for alerts"
  type        = number
  default     = 10
}

# ASE Small App Service Plan Instance Thresholds
variable "ase_small_app_service_plan_instances_threshold" {
  description = "ASE small App Service plan instances threshold for alerts"
  type        = number
  default     = 15
}

# ASE Total Front End Instances Thresholds
variable "ase_total_front_end_instances_threshold" {
  description = "ASE total front end instances threshold for alerts"
  type        = number
  default     = 10
}

# ASE Data In Thresholds (in bytes)
variable "ase_data_in_threshold" {
  description = "ASE data in threshold for alerts (in bytes)"
  type        = number
  default     = 10737418240 # 10 GB
}

# ASE Data Out Thresholds (in bytes)
variable "ase_data_out_threshold" {
  description = "ASE data out threshold for alerts (in bytes)"
  type        = number
  default     = 10737418240 # 10 GB
}

# ASE Average Response Time Thresholds (in seconds)
variable "ase_average_response_time_threshold" {
  description = "ASE average response time threshold for alerts (in seconds)"
  type        = number
  default     = 5

  validation {
    condition     = var.ase_average_response_time_threshold > 0
    error_message = "The ase_average_response_time_threshold must be greater than 0."
  }
}

# ASE HTTP Queue Length Thresholds
variable "ase_http_queue_length_threshold" {
  description = "ASE HTTP queue length threshold for alerts"
  type        = number
  default     = 100

  validation {
    condition     = var.ase_http_queue_length_threshold >= 0
    error_message = "The ase_http_queue_length_threshold must be non-negative."
  }
}

# ASE HTTP 2xx Response Thresholds
variable "ase_http_2xx_threshold" {
  description = "ASE HTTP 2xx response count threshold for alerts (minimum expected)"
  type        = number
  default     = 100
}

# ASE HTTP 3xx Response Thresholds
variable "ase_http_3xx_threshold" {
  description = "ASE HTTP 3xx response count threshold for alerts"
  type        = number
  default     = 50
}

# ASE HTTP 4xx Response Thresholds
variable "ase_http_4xx_threshold" {
  description = "ASE HTTP 4xx response count threshold for alerts"
  type        = number
  default     = 25

  validation {
    condition     = var.ase_http_4xx_threshold >= 0
    error_message = "The ase_http_4xx_threshold must be non-negative."
  }
}

# ASE HTTP 5xx Response Thresholds
variable "ase_http_5xx_threshold" {
  description = "ASE HTTP 5xx response count threshold for alerts"
  type        = number
  default     = 10

  validation {
    condition     = var.ase_http_5xx_threshold >= 0
    error_message = "The ase_http_5xx_threshold must be non-negative."
  }
}

# ASE HTTP 401 Response Thresholds
variable "ase_http_401_threshold" {
  description = "ASE HTTP 401 response count threshold for alerts"
  type        = number
  default     = 15
}

# ASE HTTP 403 Response Thresholds
variable "ase_http_403_threshold" {
  description = "ASE HTTP 403 response count threshold for alerts"
  type        = number
  default     = 10
}

# ASE HTTP 404 Response Thresholds
variable "ase_http_404_threshold" {
  description = "ASE HTTP 404 response count threshold for alerts"
  type        = number
  default     = 20
}

# ASE HTTP 406 Response Thresholds
variable "ase_http_406_threshold" {
  description = "ASE HTTP 406 response count threshold for alerts"
  type        = number
  default     = 5
}



# ASE HTTP 502 Response Thresholds
variable "ase_http_502_threshold" {
  description = "ASE HTTP 502 response count threshold for alerts"
  type        = number
  default     = 5
}

# ASE HTTP 503 Response Thresholds
variable "ase_http_503_threshold" {
  description = "ASE HTTP 503 response count threshold for alerts"
  type        = number
  default     = 5
}

# ASE Requests in Application Queue Thresholds
variable "ase_requests_in_application_queue_threshold" {
  description = "ASE requests in application queue threshold for alerts"
  type        = number
  default     = 50
}

# ASE Total Requests Thresholds
variable "ase_total_requests_threshold" {
  description = "ASE total requests threshold for alerts (high volume detection)"
  type        = number
  default     = 10000

  validation {
    condition     = var.ase_total_requests_threshold >= 0
    error_message = "The ase_total_requests_threshold must be non-negative."
  }
}

# ASE IO Read Operations per Second Thresholds
variable "ase_io_read_operations_per_second_threshold" {
  description = "ASE IO read operations per second threshold for alerts"
  type        = number
  default     = 1000
}

# ASE IO Write Operations per Second Thresholds
variable "ase_io_write_operations_per_second_threshold" {
  description = "ASE IO write operations per second threshold for alerts"
  type        = number
  default     = 1000
}

# ASE Gen 0 Collections Thresholds
variable "ase_gen_0_collections_threshold" {
  description = "ASE Gen 0 garbage collections threshold for alerts"
  type        = number
  default     = 100
}

# ASE Gen 1 Collections Thresholds
variable "ase_gen_1_collections_threshold" {
  description = "ASE Gen 1 garbage collections threshold for alerts"
  type        = number
  default     = 50
}

# ASE Gen 2 Collections Thresholds
variable "ase_gen_2_collections_threshold" {
  description = "ASE Gen 2 garbage collections threshold for alerts"
  type        = number
  default     = 10
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
