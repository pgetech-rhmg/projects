variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "registry_name" {
  type        = string
  description = "Container registry name — must be 5-50 chars, alphanumeric only, globally unique"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "sku" {
  type        = string
  description = "Container registry SKU"
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium"
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Enable the admin user (username/password). Disabled by default — prefer managed-identity AcrPull. Enable only when a deploy path needs registry credentials."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access to the registry. Only enforceable on the Premium SKU."
  default     = true
}

variable "retention_policy_days" {
  type        = number
  description = "Untagged-manifest retention in days (Premium SKU only). null disables the policy."
  default     = null
}
