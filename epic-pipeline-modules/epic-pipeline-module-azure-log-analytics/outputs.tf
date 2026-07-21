output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Resource ID of the Log Analytics workspace"
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Name of the Log Analytics workspace"
}

output "workspace_customer_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
  description = "Workspace (customer) ID used by agents to connect"
}

output "primary_shared_key" {
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  description = "Primary shared key for the workspace"
  sensitive   = true
}
