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
  description = "Name of the SQL Server"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "sql_version" {
  type        = string
  description = "SQL Server version"
  default     = "12.0"
}

variable "admin_username" {
  type        = string
  description = "Administrator login username"
  default     = "epicadmin"
}

variable "admin_password" {
  type        = string
  description = "Administrator login password. If null, a random password will be generated."
  sensitive   = true
  default     = null
  nullable    = true
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled"
  default     = false
}

variable "azuread_admin" {
  type = object({
    login_username = string
    object_id      = string
  })
  description = "Azure AD administrator"
  default     = null
  nullable    = true
}

variable "databases" {
  type = list(object({
    name           = string
    sku_name       = optional(string, "S0")
    max_size_gb    = optional(number, 2)
    zone_redundant = optional(bool, false)
  }))
  description = "Databases to create"
  default     = []
}

variable "firewall_rules" {
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  description = "Firewall rules to create"
  default     = []
}

variable "enable_auditing" {
  type        = bool
  description = "Enable auditing on the SQL Server"
  default     = false
}
