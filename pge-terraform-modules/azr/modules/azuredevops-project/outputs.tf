# Azure DevOps Project Module Outputs

output "project_id" {
  description = "ID of the created Azure DevOps project"
  value       = azuredevops_project.project.id
}

output "project_name" {
  description = "Name of the Azure DevOps project"
  value       = azuredevops_project.project.name
}

output "project_url" {
  description = "URL of the Azure DevOps project"
  value       = azuredevops_project.project.process_template_id
}

output "managed_identity_id" {
  description = "Resource ID of the managed identity (MI2) - passed through from parent"
  value       = var.managed_identity_id
}

output "managed_identity_principal_id" {
  description = "Principal ID (Object ID) of the managed identity (MI2) - passed through from parent"
  value       = var.managed_identity_principal_id
}

output "managed_identity_client_id" {
  description = "Client ID (Application ID) of the managed identity (MI2) - passed through from parent"
  value       = var.managed_identity_client_id
}

output "pipeline_creators_group_id" {
  description = "ID of the pipeline creators group (for MI1) - disabled due to API issues"
  value       = null # Commented out due to group creation issues
}

# NOTE: Team group outputs removed - group management via Terraform not recommended for ADO
# Use Azure DevOps UI to manage group membership and permissions instead

# Outputs for Azure Pipelines pool removed - automatically available in ADO projects
# Outputs for GitHub pipeline removed - pipeline creation is now at ado-automation level