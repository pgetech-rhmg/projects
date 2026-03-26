# Outputs
output "storage_account_id" {
  value       = azurerm_storage_account.storage.id
  description = "ID of the storage account"
}

output "storage_account_name" {
  value       = azurerm_storage_account.storage.name
  description = "Name of the storage account"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.storage.primary_blob_endpoint
  description = "Primary blob endpoint URL"
}

output "primary_file_endpoint" {
  value       = azurerm_storage_account.storage.primary_file_endpoint
  description = "Primary file endpoint URL"
}

output "primary_access_key" {
  value       = azurerm_storage_account.storage.primary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "primary_connection_string" {
  value       = azurerm_storage_account.storage.primary_connection_string
  description = "Primary connection string"
  sensitive   = true
}

output "blob_containers" {
  value = {
    for name, container in azapi_resource.containers : name => {
      id   = container.id
      name = container.name
    }
  }
  description = "Created blob containers"
}

output "file_shares" {
  value = {
    for name, share in azapi_resource.shares : name => {
      id   = share.id
      name = share.name
    }
  }
  description = "Created file shares"
}