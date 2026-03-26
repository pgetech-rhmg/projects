#
# Filename    : azr/modules/app-service-environment/variables.tf
# Date        : 09 March 2026
# Author      : PGE
# Description : Input variables for Azure App Service Environment module
#

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "ase_name" {
  type        = string
  description = "Name of the App Service Environment"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where ASE will be deployed"
}

variable "internal_load_balancing_mode" {
  type        = string
  description = "Load balancing mode (None for public, 'Web, Publishing' for ILB)"
  default     = "None"

  validation {
    condition     = contains(["None", "Web, Publishing"], var.internal_load_balancing_mode)
    error_message = "Must be 'None' (public) or 'Web, Publishing' (internal)."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "vnet_id" {
  type        = string
  description = "ID of the VNet to link the private DNS zone to"
  default     = ""
}

variable "dns_resolver_vnet_id" {
  type        = string
  description = "ID of the DNS resolver VNet to link the private DNS zone to (for hub-spoke DNS resolution)"
  default     = ""
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Create private DNS zone for internal ASE"
  default     = true
}
