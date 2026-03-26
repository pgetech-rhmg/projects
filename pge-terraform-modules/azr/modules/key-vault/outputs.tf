/*
 * # Azure Key Vault Outputs
*/
#
# Filename    : modules/key-vault/outputs.tf
# Description : Output values from the Key Vault module
#

output "key_vault_id" {
  value       = azurerm_key_vault.keyvault.id
  description = "ID of the Key Vault"
}

output "key_vault_name" {
  value       = azurerm_key_vault.keyvault.name
  description = "Name of the Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.keyvault.vault_uri
  description = "URI of the Key Vault"
}

output "tenant_id" {
  value       = azurerm_key_vault.keyvault.tenant_id
  description = "Tenant ID of the Key Vault"
}