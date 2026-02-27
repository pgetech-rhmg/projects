output "app_service_id" {
  value       = azurerm_linux_web_app.this.id
  description = "ID of the App Service"
}

output "app_service_name" {
  value = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "Managed identity principal ID"
}

