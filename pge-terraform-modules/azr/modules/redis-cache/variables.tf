variable "name" {
  type        = string
  description = "Name of the Redis cache, must be globally unique"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "sku_name" {
  type        = string
  description = "SKU name (Basic, Standard, Premium)"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  type        = number
  description = "Size of the Redis cache (0-6 for Basic/Standard, 1-5 for Premium)"
  default     = 0
}

variable "family" {
  type        = string
  description = "SKU family (C for Basic/Standard, P for Premium)"
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "Must be 'C' (Basic/Standard) or 'P' (Premium)."
  }
}

variable "enable_non_ssl_port" {
  type        = bool
  description = "Enable the non-SSL port (6379)"
  default     = false
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = true
}

variable "maxmemory_policy" {
  type        = string
  description = "Max memory eviction policy"
  default     = "volatile-lru"
}

variable "redis_version" {
  type        = string
  description = "Redis version (4 or 6)"
  default     = "6"

  validation {
    condition     = contains(["4", "6"], var.redis_version)
    error_message = "redis_version must be either \"4\" or \"6\"."
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for Premium SKU"
  default     = []
}

variable "replicas_per_master" {
  type        = number
  description = "Number of replicas per master (Premium only)"
  default     = null
}

variable "shard_count" {
  type        = number
  description = "Number of shards for Premium cluster"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for VNet integration (Premium only)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}