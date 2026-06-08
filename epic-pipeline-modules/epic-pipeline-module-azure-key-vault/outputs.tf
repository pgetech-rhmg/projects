output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "ID of the Key Vault"
}

output "key_vault_name" {
  value       = azurerm_key_vault.this.name
  description = "Name of the Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "URI of the Key Vault"
}

output "secret_uris" {
  value = {
    for name, secret in azurerm_key_vault_secret.this :
    name => secret.versionless_id
  }
  description = "Map of secret name to versionless URI (for App Service Key Vault references)"
}
