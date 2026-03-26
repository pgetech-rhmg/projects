output "id" {
  value       = azurerm_linux_web_app.app.id
  description = "ID of the App Service"
}

output "name" {
  value       = azurerm_linux_web_app.app.name
  description = "Name of the App Service"
}

output "default_hostname" {
  value       = azurerm_linux_web_app.app.default_hostname
  description = "Default hostname of the App Service"
}

output "outbound_ip_addresses" {
  value       = azurerm_linux_web_app.app.outbound_ip_addresses
  description = "Outbound IP addresses of the App Service"
}

output "possible_outbound_ip_addresses" {
  value       = azurerm_linux_web_app.app.possible_outbound_ip_addresses
  description = "Possible outbound IP addresses of the App Service"
}

output "identity_principal_id" {
  value       = try(azurerm_linux_web_app.app.identity[0].principal_id, "")
  description = "Principal ID of the managed identity"
}

output "identity_tenant_id" {
  value       = try(azurerm_linux_web_app.app.identity[0].tenant_id, "")
  description = "Tenant ID of the managed identity"
}

output "custom_domain_verification_id" {
  value       = azurerm_linux_web_app.app.custom_domain_verification_id
  description = "Custom domain verification ID"
}

output "url" {
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
  description = "URL of the App Service"
}
