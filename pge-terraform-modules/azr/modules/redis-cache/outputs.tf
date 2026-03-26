output "redis_cache_id" {
  value       = azurerm_redis_cache.redis.id
  description = "ID of the Redis cache"
}

output "redis_cache_name" {
  value       = azurerm_redis_cache.redis.name
  description = "Name of the Redis cache"
}

output "hostname" {
  value       = azurerm_redis_cache.redis.hostname
  description = "Hostname of the Redis cache"
}

output "port" {
  value       = azurerm_redis_cache.redis.port
  description = "Non-SSL port"
}

output "ssl_port" {
  value       = azurerm_redis_cache.redis.ssl_port
  description = "SSL port"
}

output "primary_access_key" {
  value       = azurerm_redis_cache.redis.primary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "secondary_access_key" {
  value       = azurerm_redis_cache.redis.secondary_access_key
  description = "Secondary access key"
  sensitive   = true
}

output "primary_connection_string" {
  value       = azurerm_redis_cache.redis.primary_connection_string
  description = "Primary connection string"
  sensitive   = true
}

output "secondary_connection_string" {
  value       = azurerm_redis_cache.redis.secondary_connection_string
  description = "Secondary connection string"
  sensitive   = true
}