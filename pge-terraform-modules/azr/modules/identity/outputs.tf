# Outputs for Managed Identity

output "managed_identity_id" {
  description = "Managed Identity resource ID"
  value       = azapi_resource.mi.id
}

output "managed_identity_name" {
  description = "Managed Identity name"
  value       = azapi_resource.mi.name
}

output "managed_identity_client_id" {
  description = "Managed Identity client ID (Application ID)"
  value       = azapi_resource.mi.output.properties.clientId
}

output "managed_identity_principal_id" {
  description = "Managed Identity principal ID (Object ID)"
  value       = azapi_resource.mi.output.properties.principalId
}

output "managed_identity_tenant_id" {
  description = "Managed Identity tenant ID"
  value       = azapi_resource.mi.output.properties.tenantId
}

output "federated_credential_ids" {
  description = "Federated credential resource IDs"
  value = {
    tfc    = azapi_resource.tfc.id
    github = azapi_resource.github.id
    # NOTE: ADO federated credential is now created in WS2 (ado-automation)
  }
}

# NOTE: ADO federated credential subject is now output from WS2 (ado-automation)
# after the service connection is created with the actual Entra ID issuer/subject

output "role_assignment_ids" {
  description = "RBAC role assignment IDs"
  value = merge(
    { contributor = azurerm_role_assignment.contributor.id },
    { for k, v in azurerm_role_assignment.additional_roles : k => v.id }
  )
}