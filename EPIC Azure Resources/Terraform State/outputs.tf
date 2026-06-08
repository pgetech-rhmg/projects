output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Resource group containing the state backend"
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Storage account name — use in backend config"
}

output "container_name" {
  value       = azurerm_storage_container.tfstate.name
  description = "Blob container name — use in backend config"
}

output "primary_access_key" {
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
  description = "Storage account access key — store in ADO variable group or Key Vault"
}
