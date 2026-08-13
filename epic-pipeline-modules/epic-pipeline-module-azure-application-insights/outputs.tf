output "id" {
  value       = azurerm_application_insights.this.id
  description = "Resource ID of the Application Insights component"
}

output "name" {
  value       = azurerm_application_insights.this.name
  description = "Name of the Application Insights component"
}

output "app_id" {
  value       = azurerm_application_insights.this.app_id
  description = "Application ID (used by the Application Insights REST API)"
}

output "instrumentation_key" {
  value       = azurerm_application_insights.this.instrumentation_key
  description = "Instrumentation key (legacy APPINSIGHTS_INSTRUMENTATIONKEY setting)"
  sensitive   = true
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Connection string (modern APPLICATIONINSIGHTS_CONNECTION_STRING setting)"
  sensitive   = true
}
