output "workspace_id" {
  description = "TFC workspace ID"
  value       = tfe_workspace.partner_workspace.id
}

output "workspace_name" {
  description = "TFC workspace name"
  value       = tfe_workspace.partner_workspace.name
}

output "workspace_url" {
  description = "TFC workspace URL"
  value       = "https://app.terraform.io/app/${var.tfc_organization}/workspaces/${tfe_workspace.partner_workspace.name}"
}

output "variable_ids" {
  description = "Map of variable names to IDs"
  value = {
    # OIDC configuration
    arm_use_oidc = tfe_variable.arm_use_oidc.id
    # ARM_* variables removed - now provided by OIDC variable set
    partner_name        = tfe_variable.partner_name.id
    environment         = tfe_variable.environment.id
    resource_group_name = tfe_variable.resource_group_name.id
    vnet_name           = tfe_variable.vnet_name.id
  }
}