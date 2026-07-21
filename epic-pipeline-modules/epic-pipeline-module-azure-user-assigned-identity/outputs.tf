output "identity_id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "Resource ID of the user-assigned identity"
}

output "identity_name" {
  value       = azurerm_user_assigned_identity.this.name
  description = "Name of the user-assigned identity"
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Principal (object) ID of the identity — used in role assignments"
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID of the identity — used by workloads for MSI auth"
}
