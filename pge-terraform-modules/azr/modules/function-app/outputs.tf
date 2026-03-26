
# Outputs
output "function_app_id" {
  value       = azurerm_linux_function_app.function.id
  description = "ID of the Function App"
}

output "function_app_name" {
  value       = azurerm_linux_function_app.function.name
  description = "Name of the Function App"
}

output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.function.default_hostname
  description = "Default hostname of the Function App"
}

output "function_app_identity" {
  value       = try(azurerm_linux_function_app.function.identity[0], null)
  description = "Identity block of the Function App"
}

output "storage_account_name" {
  value       = local.storage_account_name
  description = "Storage account name used by the Function App"
}
