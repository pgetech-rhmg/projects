

# -----------------------------------------------------------------------------
# Azure Hub-Peering Module
#
# This module creates a bidirectional peering relationship between a spoke
# ("partner") virtual network and a central hub virtual network in Azure.  It
# leverages the azapi provider to interact with the Microsoft.Network
# peering API which allows fine-grained control over peering properties.
#
# Module: azr/modules/hub-peering
# Author: PG&E
# Created: Mar 11, 2026
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}


module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Parse hub VNet details from resource ID
locals {
  hub_vnet_name = element(split("/", var.hub_vnet_id), length(split("/", var.hub_vnet_id)) - 1)
}

# ============================================================================
# BIDIRECTIONAL VNET PEERING
# ============================================================================
# Creates peering in both directions:
# 1. Partner VNet → Hub VNet (allows partner to access hub/firewall)
# 2. Hub VNet → Partner VNet (allows hub to forward traffic to partner)
#
# Settings:
# - allowVirtualNetworkAccess: Allow VMs in peered VNets to communicate
# - allowForwardedTraffic: Allow forwarded traffic from hub (firewall routing)
# - allowGatewayTransit: Hub can share its gateway with partner
# - useRemoteGateways: Partner uses hub's gateway (VPN/ExpressRoute)

# Create peering from partner VNet to hub VNet
# Partner → Hub: "Allow partner VNet to access hub VNet"
resource "azapi_resource" "partner_to_hub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01"
  name      = "peer-${var.partner_vnet_name}-to-${local.hub_vnet_name}"
  parent_id = var.partner_vnet_id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = var.hub_vnet_id
      }
      # Allow partner VNet to access resources in hub VNet
      allowVirtualNetworkAccess = true
      # Allow partner to receive forwarded traffic from hub (firewall routing)
      allowForwardedTraffic = true
      # Partner does not provide gateway transit (hub does)
      allowGatewayTransit = false
      # Partner uses hub's remote gateway (VPN/ExpressRoute if available)
      useRemoteGateways = var.use_remote_gateways
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

# Create peering from hub VNet to partner VNet
# Hub → Partner: "Allow hub VNet to access partner VNet"
resource "azapi_resource" "hub_to_partner" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01"
  name      = "peer-${local.hub_vnet_name}-to-${var.partner_vnet_name}"
  parent_id = var.hub_vnet_id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = var.partner_vnet_id
      }
      # Allow hub VNet to access resources in partner VNet
      allowVirtualNetworkAccess = true
      # Allow hub to forward traffic to partner (firewall routing)
      allowForwardedTraffic = true
      # Hub provides gateway transit to partner VNets
      allowGatewayTransit = var.hub_gateway_transit
      # Hub does not use partner's gateway
      useRemoteGateways = false
    }
  }

  # Ensure partner peering is created first for proper bidirectional sync
  depends_on = [azapi_resource.partner_to_hub]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

