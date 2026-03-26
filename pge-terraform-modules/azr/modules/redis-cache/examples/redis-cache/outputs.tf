# ============================================================================
# Outputs
# ============================================================================

output "redis_cache_id" {
  value       = module.azurerm_redis_cache.redis_cache_id
  description = "ID of the Redis cache"
}

output "redis_cache_name" {
  value       = module.azurerm_redis_cache.redis_cache_name
  description = "Name of the Redis cache"
}

output "hostname" {
  value       = module.azurerm_redis_cache.hostname
  description = "Hostname of the Redis cache"
}

output "port" {
  value       = module.azurerm_redis_cache.port
  description = "Non-SSL port"
}

output "ssl_port" {
  value       = module.azurerm_redis_cache.ssl_port
  description = "SSL port"
}

output "primary_access_key" {
  value       = module.azurerm_redis_cache.primary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "secondary_access_key" {
  value       = module.azurerm_redis_cache.secondary_access_key
  description = "Secondary access key"
  sensitive   = true
}

output "primary_connection_string" {
  value       = module.azurerm_redis_cache.primary_connection_string
  description = "Primary connection string"
  sensitive   = true
}

output "secondary_connection_string" {
  value       = module.azurerm_redis_cache.secondary_connection_string
  description = "Secondary connection string"
  sensitive   = true
}