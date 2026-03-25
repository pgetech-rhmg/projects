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

variable "key_vault_name" {
  type        = string
  description = "Name of the Key Vault — must be 3-24 chars, alphanumeric and hyphens"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium"
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted vaults and secrets"
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90"
  }
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection to prevent permanent deletion during retention period"
  default     = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use Azure RBAC instead of vault access policies"
  default     = true
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Azure VMs to retrieve certificates stored as secrets"
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys"
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Azure Resource Manager to retrieve secrets"
  default     = false
}

variable "network_acls" {
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network ACL rules for the Key Vault"
  default     = null
  nullable    = true
}

variable "secrets" {
  type        = map(string)
  description = "Initial secrets to create — map of secret name to secret value"
  default     = {}
  sensitive   = true
}
