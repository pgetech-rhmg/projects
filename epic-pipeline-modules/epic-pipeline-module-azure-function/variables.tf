variable "tenant_id" {
  type        = string
  description = "Tenant id"
}

variable "subscription_id" {
  type        = string
  description = "Subscription id"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "function_app_name" {
  type        = string
  description = "Name of the Function App"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account for Function App state"
}

variable "storage_account_access_key" {
  type        = string
  description = "Storage account access key"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "service_plan_name" {
  type        = string
  description = "Name of the App Service Plan. If null, creates a consumption plan named after the function app."
  default     = null
  nullable    = true
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU. Y1=Consumption, EP1/EP2/EP3=Premium, B1/S1=Dedicated."
  default     = "Y1"
}

variable "runtime" {
  type        = string
  description = "Application runtime"
  default     = "node"

  validation {
    condition     = contains(["node", "dotnet", "python"], var.runtime)
    error_message = "runtime must be one of: node, dotnet, python"
  }
}

variable "runtime_version" {
  type        = string
  description = "Runtime-specific version. If null, uses defaults: node=20, dotnet=10.0, python=3.11."
  default     = null
  nullable    = true
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings"
  default     = {}
}

variable "key_vault_secret_refs" {
  type        = map(string)
  description = "App settings mapped to Key Vault Secret URIs"
  default     = {}
}

variable "https_only" {
  type        = bool
  description = "Enforce HTTPS-only traffic"
  default     = true
}

variable "functions_extension_version" {
  type        = string
  description = "Azure Functions runtime version"
  default     = "~4"
}
