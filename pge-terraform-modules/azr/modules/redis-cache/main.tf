/*
 * # Azure Redis Cache Module
 * Terraform module which creates SAF2.0 Azure Cache for Redis instance
*/
#
#  Filename    : modules/redis-cache/main.tf
#  Date        : 24 Feb 2026
#  Author      : PGE
#  Description : Creation of Azure Cache for Redis with optional private endpoint. Supports Basic, Standard, and Premium SKUs with configurable capacity, family, and other settings.
#

terraform {
  required_version = ">= 1.1.0"
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

resource "azurerm_redis_cache" "redis" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  non_ssl_port_enabled          = var.enable_non_ssl_port
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  redis_version                 = var.redis_version

  # Premium SKU options
  zones               = var.sku_name == "Premium" ? var.zones : null
  replicas_per_master = var.sku_name == "Premium" ? var.replicas_per_master : null
  shard_count         = var.sku_name == "Premium" ? var.shard_count : null
  subnet_id           = var.sku_name == "Premium" ? var.subnet_id : null

  redis_configuration {
    maxmemory_policy = var.maxmemory_policy
  }

  tags = local.module_tags
}
