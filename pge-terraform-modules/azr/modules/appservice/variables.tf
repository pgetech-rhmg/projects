variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "app_service_name" {
  type        = string
  description = "Name of the App Service"
}

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan"
}

variable "runtime" {
  type        = string
  description = "Runtime stack (dotnet, python, java, nodejs)"
  default     = "dotnet"
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g., 8.0, 3.11, 17, 20.0)"
  default     = "8.0"
}

variable "app_service_environment_id" {
  type        = string
  description = "ID of App Service Environment (optional)"
  default     = ""
}

variable "enable_https_only" {
  type        = bool
  description = "Enable HTTPS only"
  default     = true
}

variable "use_32_bit_worker" {
  type        = bool
  description = "Use 32-bit worker processes"
  default     = false
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables)"
  default     = {}
}

variable "connection_strings" {
  type = map(object({
    type  = string
    value = string
  }))
  description = "Connection strings for databases and services"
  default     = {}
}

variable "health_check_path" {
  type        = string
  description = "Health check path"
  default     = "/health"
}

variable "identity_type" {
  type        = string
  description = "Type of identity (SystemAssigned, UserAssigned, or SystemAssigned,UserAssigned)"
  default     = "SystemAssigned"
}

variable "managed_identity_ids" {
  type        = list(string)
  description = "List of managed identity IDs (for UserAssigned)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "application_insights_connection_string" {
  type        = string
  description = "Application Insights connection string for APM"
  default     = ""
}

variable "application_insights_instrumentation_key" {
  type        = string
  description = "Application Insights instrumentation key (legacy, use connection string instead)"
  default     = ""
}
