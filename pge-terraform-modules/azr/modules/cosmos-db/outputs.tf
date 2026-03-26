output "cosmos_db_id" {
  value       = azurerm_cosmosdb_account.cosmos.id
  description = "ID of the Cosmos DB account"
}

output "cosmos_db_name" {
  value       = azurerm_cosmosdb_account.cosmos.name
  description = "Name of the Cosmos DB account"
}

output "endpoint" {
  value       = azurerm_cosmosdb_account.cosmos.endpoint
  description = "Endpoint of the Cosmos DB account"
}

output "primary_key" {
  value       = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive   = true
  description = "Primary key for the Cosmos DB account (use with caution, RBAC preferred)"
}

output "database_name" {
  value       = azurerm_cosmosdb_sql_database.database[0].name
  description = "Name of the created database"
}

output "container_name" {
  value       = azurerm_cosmosdb_sql_container.container[0].name
  description = "Name of the created container"
}
output "key_vault_key_id" {
  value       = var.key_vault_key_id != "" ? var.key_vault_key_id : null
  description = "Key Vault key ID used for customer-managed keys (CMK) encryption, or null if Microsoft-managed keys are used"

}