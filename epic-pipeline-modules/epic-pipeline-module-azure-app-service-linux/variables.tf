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

variable "service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "app_name" {
  type        = string
  description = "Name of the App Service"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU (e.g. B1, S1, P1v3)"
  default     = "B1"
}

variable "node_version" {
  type        = string
  description = "Node.js version"
  default     = "22-lts"
}

variable "dotnet_version" {
  type        = string
  description = "Dotnet version"
  default     = "10.0"
}

variable "runtime" {
  type        = string
  description = "Application runtime"
  default     = "node"

  validation {
    condition     = contains(["node", "dotnet"], var.runtime)
    error_message = "runtime must be one of: node, dotnet"
  }
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings"
  default = {}
}

variable "key_vault_secret_refs" {
  type        = map(string)
  description = "Key Vault Secret URIs."
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

