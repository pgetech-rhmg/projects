/*
 * # Azure Private Endpoint module.
 * Terraform module which creates Azure Private Endpoints for secure access to Azure services.
*/

#
# Filename    : azr/modules/private-endpoint/main.tf
# Date        : 25 February 2026
# Author      : PGE
# Description : Private Endpoint module 


terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# ============================================================================
# Private Endpoint Resource
# ============================================================================

resource "azurerm_private_endpoint" "endpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
    request_message                = var.is_manual_connection ? var.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "pdz-${var.name}"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = merge(
    var.tags,
    local.module_tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "private-endpoint"
    }
  )
}
