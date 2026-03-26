# Azure DevOps Resource Providers Module Outputs

output "registered_providers" {
  description = "List of registered resource providers"
  value       = keys(azapi_resource_action.register_providers)
}
