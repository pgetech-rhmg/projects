variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account (must be globally unique, lowercase, 3-24 chars)"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier (Standard or Premium)"
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Must be 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  description = "Storage account kind (StorageV2, BlobStorage, FileStorage, BlockBlobStorage)"
  default     = "StorageV2"
}

variable "access_tier" {
  type        = string
  description = "Access tier for BlobStorage (Hot or Cool)"
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Must be 'Hot' or 'Cool'."
  }
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "TLS1_2"
}

variable "enable_https_traffic_only" {
  type        = bool
  description = "Only allow HTTPS traffic"
  default     = true
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow public access to blobs"
  default     = false
}

variable "blob_containers" {
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  description = "List of blob containers to create"
  default     = []
}

variable "file_shares" {
  type = list(object({
    name  = string
    quota = optional(number, 50) # GB
  }))
  description = "List of file shares to create"
  default     = []
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable private endpoint for storage"
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint"
  default     = ""
}

variable "private_dns_zone_ids" {
  type = object({
    blob  = optional(string, "")
    file  = optional(string, "")
    table = optional(string, "")
    queue = optional(string, "")
  })
  description = "Private DNS zone IDs for each storage service"
  default     = {}
}

variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  description = "Network rules for storage account"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}