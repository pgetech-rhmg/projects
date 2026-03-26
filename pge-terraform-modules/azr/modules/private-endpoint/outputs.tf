# Outputs for Azure Private Endpoint module

output "private_endpoint_id" {
  value       = azurerm_private_endpoint.endpoint.id
  description = "ID of the private endpoint"
}

output "private_endpoint_name" {
  value       = azurerm_private_endpoint.endpoint.name
  description = "Name of the private endpoint"
}

output "private_ip_address" {
  value       = try(azurerm_private_endpoint.endpoint.private_service_connection[0].private_ip_address, null)
  description = "Private IP address of the endpoint"
}

output "custom_dns_configs" {
  value       = azurerm_private_endpoint.endpoint.custom_dns_configs
  description = "Custom DNS configurations"
}

output "network_interface_id" {
  value       = try(azurerm_private_endpoint.endpoint.network_interface[0].id, null)
  description = "Network interface ID"
}