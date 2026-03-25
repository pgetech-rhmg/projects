variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name — must be 3-24 chars, lowercase alphanumeric only"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier"
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be one of: Standard, Premium"
  }
}

variable "account_replication_type" {
  type        = string
  description = "Storage account replication type"
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, GRS, RAGRS, ZRS"
  }
}

variable "account_kind" {
  type        = string
  description = "Storage account kind"
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "BlockBlobStorage"], var.account_kind)
    error_message = "account_kind must be one of: StorageV2, BlobStorage, BlockBlobStorage"
  }
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "TLS1_2"
}

variable "allow_blob_public_access" {
  type        = bool
  description = "Allow public access to blobs"
  default     = false
}

variable "enable_versioning" {
  type        = bool
  description = "Enable blob versioning"
  default     = false
}

variable "enable_blob_soft_delete" {
  type        = bool
  description = "Enable blob soft delete"
  default     = true
}

variable "blob_soft_delete_days" {
  type        = number
  description = "Number of days to retain soft-deleted blobs"
  default     = 7
}

variable "enable_container_soft_delete" {
  type        = bool
  description = "Enable container soft delete"
  default     = true
}

variable "container_soft_delete_days" {
  type        = number
  description = "Number of days to retain soft-deleted containers"
  default     = 7
}

variable "containers" {
  type = list(object({
    name        = string
    access_type = string
  }))
  description = "Containers to create — access_type should be \"private\""
  default     = []
}

variable "network_rules" {
  type = object({
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network rules for the storage account"
  default     = null
}
