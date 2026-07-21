variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
    delegation = optional(object({
      name                       = string
      service_delegation_name    = string
      service_delegation_actions = list(string)
    }))
  }))
  description = "Subnets to create within the virtual network. Optional delegation delegates the subnet to a PaaS service."
  default     = []
}

variable "public_ips" {
  type = list(object({
    name              = string
    allocation_method = optional(string, "Static")
    sku               = optional(string, "Standard")
    zones             = optional(list(string), null)
  }))
  description = "Public IP addresses to create. Standard SKU + Static is the App Gateway v2 requirement."
  default     = []
}
