variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "server_name" {
  type        = string
  description = "Name of the PostgreSQL Flexible Server"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL major version"
  default     = "16"

  validation {
    condition     = contains(["13", "14", "15", "16"], var.postgresql_version)
    error_message = "postgresql_version must be one of: 13, 14, 15, 16"
  }
}

variable "sku_name" {
  type        = string
  description = "Flexible Server SKU (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)"
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  type        = number
  description = "Storage in MB"
  default     = 32768
}

variable "storage_tier" {
  type        = string
  description = "Storage performance tier"
  default     = "P4"
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention in days"
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35"
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backups"
  default     = false
}

variable "zone" {
  type        = string
  description = "Availability zone (1, 2, or 3)"
  default     = null
  nullable    = true
}

variable "admin_username" {
  type        = string
  description = "Administrator login name"
  default     = "epicadmin"
}

variable "admin_password" {
  type        = string
  description = "Administrator password. If null, a 24-character password is auto-generated"
  sensitive   = true
  default     = null
  nullable    = true
}

variable "databases" {
  type = list(object({
    name      = string
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  description = "Databases to create on the server"
  default     = []
}

variable "firewall_rules" {
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  description = "Firewall rules for public access"
  default     = []
}

variable "delegated_subnet_id" {
  type        = string
  description = "Subnet ID for private network access (VNet integration)"
  default     = null
  nullable    = true
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for FQDN resolution"
  default     = null
  nullable    = true
}
