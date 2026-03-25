output "app_service_id" {
  value       = local.is_linux ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  description = "ID of the App Service"
}

output "app_service_name" {
  value = local.is_linux ? azurerm_linux_web_app.this[0].name : azurerm_windows_web_app.this[0].name
}

output "default_hostname" {
  value = local.is_linux ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "principal_id" {
  value       = local.is_linux ? azurerm_linux_web_app.this[0].identity[0].principal_id : azurerm_windows_web_app.this[0].identity[0].principal_id
  description = "Managed identity principal ID"
}
