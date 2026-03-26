#
# Filename    : examples/keyvault/outputs.tf
# Description : Outputs from Key Vault example
#

output "key_vault_id" {
  value       = module.keyvault.key_vault_id
  description = "ID of the Key Vault"
}

output "key_vault_name" {
  value       = module.keyvault.key_vault_name
  description = "Name of the Key Vault"
}

output "key_vault_uri" {
  value       = module.keyvault.key_vault_uri
  description = "URI of the Key Vault"
}

output "tenant_id" {
  value       = module.keyvault.tenant_id
  description = "Tenant ID of the Key Vault"
}