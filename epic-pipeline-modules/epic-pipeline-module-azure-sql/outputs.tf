output "server_id" {
  value       = azurerm_mssql_server.this.id
  description = "ID of the SQL Server"
}

output "server_name" {
  value       = azurerm_mssql_server.this.name
  description = "Name of the SQL Server"
}

output "server_fqdn" {
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
  description = "Fully qualified domain name of the SQL Server"
}

output "admin_username" {
  value       = var.admin_username
  description = "Administrator login username"
}

output "admin_password" {
  value       = local.generate_password ? random_password.admin[0].result : var.admin_password
  description = "Administrator login password"
  sensitive   = true
}

output "database_ids" {
  value       = { for name, db in azurerm_mssql_database.this : name => db.id }
  description = "Map of database name to database ID"
}
