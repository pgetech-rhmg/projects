output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  value       = azapi_resource.law.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azapi_resource.law.name
}

output "log_analytics_workspace_primary_key" {
  description = "Log Analytics Workspace primary shared key"
  value       = try(azapi_resource.law.output.properties.sharedKeys.primarySharedKey, null)
  sensitive   = true
}

output "log_analytics_workspace_workspace_id" {
  description = "Log Analytics Workspace ID (customer ID)"
  value       = try(azapi_resource.law.output.properties.customerId, null)
}

output "enabled_solutions" {
  description = "Enabled Log Analytics solutions"
  value       = []
}
