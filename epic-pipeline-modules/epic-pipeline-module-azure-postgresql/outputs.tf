output "server_id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "ID of the PostgreSQL Flexible Server"
}

output "server_name" {
  value       = azurerm_postgresql_flexible_server.this.name
  description = "Name of the PostgreSQL Flexible Server"
}

output "server_fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the server"
}

output "admin_username" {
  value       = azurerm_postgresql_flexible_server.this.administrator_login
  description = "Administrator login name"
}

output "admin_password" {
  value       = local.generate_password ? random_password.admin[0].result : var.admin_password
  sensitive   = true
  description = "Administrator password"
}

output "database_names" {
  value       = [for db in azurerm_postgresql_flexible_server_database.this : db.name]
  description = "List of created database names"
}
