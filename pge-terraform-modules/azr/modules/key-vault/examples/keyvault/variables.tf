#
# Filename    : examples/keyvault/variables.tf
# Description : Variables for Key Vault example
#

variable "name" {
  type        = string
  description = "Name of the Key Vault"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}

variable "sku_name" {
  type        = string
  description = "SKU name (standard or premium)"
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Must be 'standard' or 'premium'."
  }
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Enable for Azure Disk Encryption"
  default     = false
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Enable for VM deployment"
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Enable for ARM template deployment"
  default     = false
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Enable RBAC authorization (recommended)"
  default     = true
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection (cannot be disabled once enabled)"
  default     = false
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention in days"
  default     = 7
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "network_acls" {
  type = object({
    default_action             = optional(string, "Allow")
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  description = "Network ACL configuration"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}