output "function_app_id" {
  value       = azurerm_linux_function_app.this.id
  description = "ID of the Function App"
}

output "function_app_name" {
  value       = azurerm_linux_function_app.this.name
  description = "Name of the Function App"
}

output "default_hostname" {
  value       = azurerm_linux_function_app.this.default_hostname
  description = "Default hostname of the Function App"
}

output "service_plan_id" {
  value       = azurerm_service_plan.this.id
  description = "ID of the App Service Plan"
}

output "principal_id" {
  value       = azurerm_linux_function_app.this.identity[0].principal_id
  description = "Managed identity principal ID"
}
