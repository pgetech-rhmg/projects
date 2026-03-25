############################################
# Azure Context
############################################

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID — this is the central EPIC subscription that holds shared state"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
  default     = "westus2"
}

############################################
# Resource Group
############################################

variable "resource_group_name" {
  type        = string
  description = "Resource group for EPIC shared state resources"
  default     = "rg-epic-terraform-state"
}

############################################
# Storage Account
############################################

variable "storage_account_name" {
  type        = string
  description = "Storage account name for Terraform state (3-24 chars, lowercase alphanumeric only)"
  default     = "pgeepicterraformstate"
}

variable "container_name" {
  type        = string
  description = "Blob container name for state files"
  default     = "tfstate"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account"
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.account_replication_type)
    error_message = "account_replication_type must be LRS, GRS, RAGRS, or ZRS"
  }
}

############################################
# Tags
############################################

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
