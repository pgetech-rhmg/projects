variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "dns_zones" {
  type = list(object({
    name    = string # e.g., "privatelink.vaultcore.azure.net"
    service = string # e.g., "keyvault", "redis", "blob"
  }))
  description = "List of Private DNS zones to create"
  default     = []
}

variable "virtual_network_id" {
  type        = string
  description = "ID of the VNet to link"
}

variable "partner_name" {
  type        = string
  description = "Partner name for resource naming"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
