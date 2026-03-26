output "agent_pool_id" {
  description = "ADO Agent Pool ID"
  value       = azuredevops_agent_pool.pool.id
}

output "agent_pool_name" {
  description = "ADO Agent Pool name"
  value       = azuredevops_agent_pool.pool.name
}

output "vmss_id" {
  description = "Virtual Machine Scale Set ID"
  value       = try(azurerm_linux_virtual_machine_scale_set.build_agents[0].id, "")
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.ado_vnet.id
}

output "subnet_id" {
  description = "Build agents subnet ID"
  value       = azurerm_subnet.ado_agents.id
}

output "ssh_public_key" {
  description = "Public SSH key for connecting to agents"
  value       = tls_private_key.build_agents.public_key_openssh
  sensitive   = false
}
