
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "function_app_name" {
  type        = string
  description = "Name of the Function App"
}

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account for Function App"
}

variable "storage_account_access_key" {
  type        = string
  description = "Access key for the storage account"
  sensitive   = true
}

variable "runtime" {
  type        = string
  description = "Runtime stack (dotnet, python, java, nodejs, powershell)"
  default     = "dotnet"
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g., 8.0, 3.11, 17, 20)"
  default     = "8.0"
}

variable "functions_extension_version" {
  type        = string
  description = "Azure Functions runtime version (~4 for v4)"
  default     = "~4"
}

variable "app_settings" {
  type        = map(string)
  description = "Additional app settings for the Function App"
  default     = {}
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

variable "enable_https_only" {
  type        = bool
  description = "Enable HTTPS only"
  default     = true
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
  description = "Application Insights instrumentation key (legacy)"
  default     = ""
}
