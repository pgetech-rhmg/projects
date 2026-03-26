# Hub Peering Module
# Creates VNet peering to hub (firewall) VNet

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_vnet_id" {
  description = "Partner VNet resource ID"
  type        = string
}

variable "partner_vnet_name" {
  description = "Partner VNet name"
  type        = string
}

# variable "partner_resource_group" {
#   description = "Partner resource group name"
#   type        = string
# }

variable "hub_vnet_id" {
  description = "Hub VNet resource ID"
  type        = string
}

# variable "hub_resource_group" {
#   description = "Hub resource group name"
#   type        = string
# }

# variable "subscription_id" {
#   description = "Azure subscription ID"
#   type        = string
# }

variable "use_remote_gateways" {
  description = "Allow partner VNet to use hub's remote gateway (VPN/ExpressRoute). Set to true if hub has a gateway."
  type        = bool
  default     = false
}

variable "hub_gateway_transit" {
  description = "Allow hub VNet to provide gateway transit to partner VNets. Set to true if hub has a gateway."
  type        = bool
  default     = false
}
