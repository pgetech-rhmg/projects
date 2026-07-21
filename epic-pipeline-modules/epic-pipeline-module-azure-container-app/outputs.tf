output "environment_id" {
  value       = azurerm_container_app_environment.this.id
  description = "Resource ID of the Container App Environment"
}

output "environment_static_ip_address" {
  value       = azurerm_container_app_environment.this.static_ip_address
  description = "Static IP of the environment — use for a PostgreSQL firewall rule allowing the app to reach the DB"
}

output "environment_default_domain" {
  value       = azurerm_container_app_environment.this.default_domain
  description = "Default domain suffix of the environment"
}

output "container_app_id" {
  value       = azurerm_container_app.this.id
  description = "Resource ID of the Container App"
}

output "container_app_name" {
  value       = azurerm_container_app.this.name
  description = "Name of the Container App"
}

output "ingress_fqdn" {
  value       = azurerm_container_app.this.ingress[0].fqdn
  description = "Ingress FQDN of the Container App — wire into an Application Gateway backend pool or DNS"
}

output "latest_revision_fqdn" {
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "FQDN of the latest revision"
}
