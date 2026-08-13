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
    condition     = contains(["13", "14", "15", "16", "17", "18"], var.postgresql_version)
    error_message = "postgresql_version must be one of: 13, 14, 15, 16, 17, 18"
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
  description = "Administrator password. If null, a 24-character password is auto-generated. If you pass a value that is unknown at plan time (e.g. random_password.x.result created in the same run), also set generate_admin_password = false so the module doesn't try to derive that intent from an unknown value."
  sensitive   = true
  default     = null
  nullable    = true
}

variable "generate_admin_password" {
  type        = bool
  description = <<-EOT
    Explicitly control whether the module generates the admin password.
    - null (default): infer from admin_password (generate when it is null).
      Safe ONLY when admin_password is known at plan time (a literal or an
      already-existing value).
    - false: never generate; use the supplied admin_password. Set this when you
      pass an apply-time/computed admin_password (e.g. random_password.x.result)
      so `count` stays plan-known and avoids "Invalid count argument".
    - true: always generate; admin_password is ignored.
  EOT
  default     = null
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

variable "server_configurations" {
  type        = map(string)
  description = "Server parameters (azurerm_postgresql_flexible_server_configuration), keyed by parameter name. E.g. { \"azure.extensions\" = \"UUID-OSSP,FUZZYSTRMATCH\" }."
  default     = {}
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
