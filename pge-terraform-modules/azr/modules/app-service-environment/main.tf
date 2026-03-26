#
# Filename    : azr/modules/app-service-environment/main.tf
# Date        : 09 March 2026
# Author      : PGE
# Description : Creates an isolated App Service Environment for deploying App Services with network isolation and custom domain support
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

# Workspace information module for SAF2.0 compliance tagging
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Local variables for module configuration and tagging
locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# ============================================================================
# App Service Environment v3
# ============================================================================

resource "azurerm_app_service_environment_v3" "ase" {
  name                = var.ase_name
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  # ILB mode for internal-only access (more secure for partners)
  internal_load_balancing_mode = var.internal_load_balancing_mode

  tags = local.module_tags
}

# ============================================================================
# Private DNS Zone for Internal ASE
# ============================================================================
# When using ILB ASE (internal load balancing), a private DNS zone is required
# for name resolution within the VNet. The zone name matches the ASE's DNS suffix.
# Records needed:
#   * → ASE internal IP (for app endpoints like app-name.ase-name.appserviceenvironment.net)
#   @ → ASE internal IP (for root domain)
#   *.scm → ASE internal IP (for Kudu/deployment endpoints)

resource "azurerm_private_dns_zone" "ase" {
  count               = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? 1 : 0
  name                = azurerm_app_service_environment_v3.ase.dns_suffix
  resource_group_name = var.resource_group_name

  tags = local.module_tags
}

# Link private DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "ase" {
  count                 = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" && var.vnet_id != "" ? 1 : 0
  name                  = "link-${var.ase_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ase[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = local.module_tags

  lifecycle {
    ignore_changes = all
  }
}

# Link private DNS zone to DNS Resolver VNet (Hub)
# This is required for hub-spoke DNS architecture where custom DNS server
# forwards queries to Azure DNS (168.63.129.16) from the hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "ase_dns_resolver" {
  count                 = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" && var.dns_resolver_vnet_id != "" ? 1 : 0
  name                  = "vnet-link-dns-resolver"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ase[0].name
  virtual_network_id    = var.dns_resolver_vnet_id
  registration_enabled  = false

  tags = local.module_tags

  lifecycle {
    ignore_changes = all
  }
}

# Wildcard A record for app endpoints (e.g., app-name.ase-name.appserviceenvironment.net)
resource "azurerm_private_dns_a_record" "ase_wildcard" {
  count               = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? 1 : 0
  name                = "*"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
}

# Root A record for ASE domain
resource "azurerm_private_dns_a_record" "ase_root" {
  count               = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? 1 : 0
  name                = "@"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
}

# SCM wildcard A record for deployment/Kudu endpoints
resource "azurerm_private_dns_a_record" "ase_scm" {
  count               = var.create_private_dns_zone && var.internal_load_balancing_mode == "Web, Publishing" ? 1 : 0
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
}
