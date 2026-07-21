output "registry_id" {
  value       = azurerm_container_registry.this.id
  description = "Resource ID of the container registry (use as the scope for AcrPull role assignments)"
}

output "registry_name" {
  value       = azurerm_container_registry.this.name
  description = "Name of the container registry"
}

output "login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "Login server hostname (e.g. myregistry.azurecr.io)"
}

output "admin_username" {
  value       = azurerm_container_registry.this.admin_enabled ? azurerm_container_registry.this.admin_username : null
  description = "Admin username, or null when admin is disabled"
}

output "admin_password" {
  value       = azurerm_container_registry.this.admin_enabled ? azurerm_container_registry.this.admin_password : null
  description = "Admin password, or null when admin is disabled"
  sensitive   = true
}
