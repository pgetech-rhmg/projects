# Azure DevOps Service Connections Module Outputs

output "azure_connection_id" {
  description = "ID of the Azure service connection"
  value       = var.create_azure_connection ? azuredevops_serviceendpoint_azurerm.azure_connection[0].id : null
}

output "azure_connection_name" {
  description = "Name of the Azure service connection"
  value       = var.create_azure_connection ? azuredevops_serviceendpoint_azurerm.azure_connection[0].service_endpoint_name : null
}

output "azure_connection_federation_issuer" {
  description = "Workload Identity Federation issuer URL for the Azure service connection"
  value       = var.create_azure_connection ? azuredevops_serviceendpoint_azurerm.azure_connection[0].workload_identity_federation_issuer : null
}

output "azure_connection_federation_subject" {
  description = "Workload Identity Federation subject for the Azure service connection"
  value       = var.create_azure_connection ? azuredevops_serviceendpoint_azurerm.azure_connection[0].workload_identity_federation_subject : null
}

output "federated_credential_id" {
  description = "ID of the federated identity credential created on MI2"
  value       = var.create_azure_connection && var.managed_identity_id != "" ? azapi_resource.federated_credential[0].id : null
}

output "github_connection_id" {
  description = "ID of the GitHub PAT service connection"
  value       = var.create_github_connection ? azuredevops_serviceendpoint_github.github_connection[0].id : null
}

output "github_connection_name" {
  description = "Name of the GitHub PAT service connection"
  value       = var.create_github_connection ? azuredevops_serviceendpoint_github.github_connection[0].service_endpoint_name : null
}

output "github_app_connection_id" {
  description = "ID of the GitHub App service connection"
  value       = var.create_github_app_connection ? azuredevops_serviceendpoint_github.github_app_connection[0].id : null
}

output "github_app_connection_name" {
  description = "Name of the GitHub App service connection"
  value       = var.create_github_app_connection ? azuredevops_serviceendpoint_github.github_app_connection[0].service_endpoint_name : null
}

# SonarQube Service Connection Outputs
output "sonarqube_connection_id" {
  description = "ID of the SonarQube service connection"
  value       = var.create_sonarqube_connection ? azuredevops_serviceendpoint_sonarqube.sonarqube_connection[0].id : null
}

output "sonarqube_connection_name" {
  description = "Name of the SonarQube service connection"
  value       = var.create_sonarqube_connection ? azuredevops_serviceendpoint_sonarqube.sonarqube_connection[0].service_endpoint_name : null
}

# JFrog Artifactory Service Connection Outputs
output "jfrog_connection_id" {
  description = "ID of the JFrog Artifactory service connection"
  value       = var.create_jfrog_connection ? azuredevops_serviceendpoint_generic.jfrog_connection[0].id : null
}

output "jfrog_connection_name" {
  description = "Name of the JFrog Artifactory service connection"
  value       = var.create_jfrog_connection ? azuredevops_serviceendpoint_generic.jfrog_connection[0].service_endpoint_name : null
}

output "custom_connection_ids" {
  description = "Map of custom service connection IDs"
  value       = { for k, v in azuredevops_serviceendpoint_generic.custom_connection : k => v.id }
}

output "custom_connection_names" {
  description = "Map of custom service connection names"
  value       = { for k, v in azuredevops_serviceendpoint_generic.custom_connection : k => v.service_endpoint_name }
}
