output "storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "ID of the storage account"
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Primary blob service endpoint"
}

output "primary_access_key" {
  value       = azurerm_storage_account.this.primary_access_key
  description = "Primary access key for the storage account"
  sensitive   = true
}

output "primary_connection_string" {
  value       = azurerm_storage_account.this.primary_connection_string
  description = "Primary connection string for the storage account"
  sensitive   = true
}

output "primary_web_endpoint" {
  value       = azurerm_storage_account.this.primary_web_endpoint
  description = "Static website endpoint URL (null when static hosting is disabled)"
}

output "primary_web_host" {
  value       = azurerm_storage_account.this.primary_web_host
  description = "Static website host (no scheme) — use as an Application Gateway backend pool FQDN"
}

output "static_website_enabled" {
  value       = var.static_website != null
  description = "Whether static website hosting was enabled on this account"
}
