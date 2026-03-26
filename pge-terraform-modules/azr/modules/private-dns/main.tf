/*
 * # Azure Private DNS Zone module
 * Terraform module which creates Azure Private DNS Zones with optional VNet links for private endpoint resolution.
*/
#
# Filename    : azr/modules/private-dns/main.tf
# Date        : 03/09/2026
# Author      : STCO
#

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# Workspace Info & Module Tags
# ============================================================================

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# ============================================================================
# Private DNS Zones
# ============================================================================

resource "azurerm_private_dns_zone" "zones" {
  for_each = { for zone in var.dns_zones : zone.service => zone }

  name                = each.value.name
  resource_group_name = var.resource_group_name

  tags = merge(
    local.module_tags,
    {
      "managed_by" = "terraform"
      "service"    = each.value.service
    }
  )
}

# ============================================================================
# VNet Links
# ============================================================================

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = { for zone in var.dns_zones : zone.service => zone }

  name                  = "link-${each.value.service}-${var.partner_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false

  tags = merge(
    local.module_tags,
    {
      "managed_by" = "terraform"
      "service"    = each.value.service
    }
  )

  lifecycle {
    ignore_changes = all
  }
}