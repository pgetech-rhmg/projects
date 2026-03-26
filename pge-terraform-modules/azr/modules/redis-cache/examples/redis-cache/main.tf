/*
 * # Azure Redis Cache Module
 * Terraform example which creates SAF2.0 Azure Cache for Redis instance
*/
#
#  Filename    : modules/redis-cache/main.tf
#  Date        : 19 Feb 2026
#  Author      : Paul Kelley (p3kk@pge.com)
#  Description : Creation of Azure Cache for Redis with optional private endpoint. Supports Basic, Standard, and Premium SKUs with configurable capacity, family, and other settings.
#



module "azurerm_redis_cache" {
  source                        = "../../"
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  enable_non_ssl_port           = var.enable_non_ssl_port
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  redis_version                 = var.redis_version
  zones                         = var.zones
  replicas_per_master           = var.replicas_per_master
  shard_count                   = var.shard_count
  subnet_id                     = var.subnet_id
  maxmemory_policy              = var.maxmemory_policy
  tags                          = var.tags

}

