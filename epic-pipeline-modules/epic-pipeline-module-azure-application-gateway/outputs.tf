output "gateway_id" {
  value       = azurerm_application_gateway.this.id
  description = "Resource ID of the Application Gateway"
}

output "gateway_name" {
  value       = azurerm_application_gateway.this.name
  description = "Name of the Application Gateway"
}

output "backend_address_pool_ids" {
  value       = { for p in azurerm_application_gateway.this.backend_address_pool : p.name => p.id }
  description = "Map of backend address pool name => ID"
}
