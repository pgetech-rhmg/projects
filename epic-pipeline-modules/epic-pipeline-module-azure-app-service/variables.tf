############################################
# Azure Context
############################################

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

############################################
# Resource Naming
############################################

variable "service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "app_name" {
  type        = string
  description = "Name of the App Service"
}

############################################
# OS & Runtime
############################################

variable "os_type" {
  type        = string
  description = "Operating system type"
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be Linux or Windows"
  }
}

variable "runtime" {
  type        = string
  description = "Application runtime"
  default     = "node"

  validation {
    condition     = contains(["node", "dotnet", "python", "java", "php"], var.runtime)
    error_message = "runtime must be one of: node, dotnet, python, java, php"
  }
}

variable "runtime_version" {
  type        = string
  description = "Runtime version. If null, uses a sensible default per runtime."
  default     = null
}

############################################
# Service Plan
############################################

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU (e.g. F1, B1, S1, P1v3)"
  default     = "B1"
}

############################################
# Application Configuration
############################################

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables)"
  default     = {}
}

variable "key_vault_secret_refs" {
  type        = map(string)
  description = "App settings mapped to Key Vault Secret URIs — resolved at runtime via managed identity"
  default     = {}
}

############################################
# Tags
############################################

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
