# Azure Managed DevOps Pool Module Outputs

output "pool_id" {
  description = "Azure resource ID of the Azure Managed DevOps Pool"
  value       = azapi_resource.managed_pool.id
}

output "ado_pool_id" {
  description = "Azure DevOps pool ID (integer) for pipeline authorization"
  value       = data.azuredevops_agent_pool.managed_pool.id
}

output "pool_name" {
  description = "Name of the managed pool"
  value       = azapi_resource.managed_pool.name
}

output "provisioning_state" {
  description = "Provisioning state of the managed pool"
  value       = try(azapi_resource.managed_pool.output.properties.provisioningState, "Unknown")
}