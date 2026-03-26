output "cosmos_db_id" {
  value       = module.cosmos_sql.cosmos_db_id
  description = "ID of the Cosmos DB account"
}

output "cosmos_db_name" {
  value       = module.cosmos_sql.cosmos_db_name
  description = "Name of the Cosmos DB account"
}

output "endpoint" {
  value       = module.cosmos_sql.endpoint
  description = "Endpoint of the Cosmos DB account"
}

output "primary_key" {
  value       = module.cosmos_sql.primary_key
  sensitive   = true
  description = "Primary key for the Cosmos DB account (use with caution, RBAC preferred)"
}

output "database_name" {
  value       = module.cosmos_sql.database_name
  description = "Name of the created database"
}

output "container_name" {
  value       = module.cosmos_sql.container_name
  description = "Name of the created container"
}
