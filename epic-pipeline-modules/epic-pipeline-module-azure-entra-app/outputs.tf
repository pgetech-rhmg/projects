output "application_id" {
  value       = azuread_application.this.id
  description = "Object ID of the application registration"
}

output "client_id" {
  value       = azuread_application.this.client_id
  description = "Client (application) ID — used by the workload for OAuth/Graph auth"
}

output "service_principal_id" {
  value       = azuread_service_principal.this.id
  description = "Object ID of the service principal"
}

output "service_principal_object_id" {
  value       = azuread_service_principal.this.object_id
  description = "Object ID of the service principal (for role assignments / group ownership)"
}

output "client_secret" {
  value       = azuread_application_password.this.value
  description = "Generated client secret — write to Key Vault, never expose downstream"
  sensitive   = true
}

output "tenant_id" {
  value       = data.azuread_client_config.current.tenant_id
  description = "Tenant ID the application is registered in"
}
