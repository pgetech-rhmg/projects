# TFC Workspace Module
# Creates Terraform Cloud workspace and injects variables

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_config" {
  description = "Partner configuration from YAML"
  type = object({
    environment = string
  })
}

variable "tfc_organization" {
  description = "Terraform Cloud organization name"
  type        = string
}

variable "workspace_name" {
  description = "TFC workspace name"
  type        = string
}

variable "managed_identity_client_id" {
  description = "Managed Identity client ID for authentication"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed Identity resource ID for attaching to App Service"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Managed Identity principal ID (Object ID) for RBAC assignments"
  type        = string
}

variable "managed_identity_name" {
  description = "Managed Identity name"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "VNet name"
  type        = string
}

variable "network_resource_group_name" {
  description = "Resource group name containing WS1 network resources"
  type        = string
  default     = ""
}

variable "compute_resource_group_name" {
  description = "Desired resource group name for WS3 compute/app resources"
  type        = string
  default     = ""
}

variable "data_resource_group_name" {
  description = "Desired resource group name for WS3 data resources"
  type        = string
  default     = ""
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "oauth_token_id" {
  description = "OAuth Token ID for VCS connection (from variable set)"
  type        = string
  default     = ""
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch for VCS integration"
  type        = string
  default     = "main"
}

variable "vcs_working_directory" {
  description = "VCS working directory path for Terraform code"
  type        = string
  default     = ""
}

variable "partner_subscription_id" {
  description = "Partner Azure subscription ID for child-automation"
  type        = string
}

variable "azuredevops_org_url" {
  description = "Azure DevOps organization URL"
  type        = string
}

variable "github_service_connection_id" {
  description = "GitHub service connection ID from WS2 (ado-automation)"
  type        = string
}

variable "tfc_token" {
  description = "Terraform Cloud API token for configuring VCS via API"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tfc_project_id" {
  description = "TFC Project ID to assign workspace to"
  type        = string
  default     = "prj-esd9dTmLP1BHAJAo"
}

variable "team_name" {
  description = "TFC team name to grant Run permissions on workspace"
  type        = string
  default     = ""
}

variable "user_email" {
  description = "User email to grant Run permissions on workspace (e.g., avas@pge.com)"
  type        = string
  default     = ""
}

variable "tfc_username" {
  description = "TFC username for team membership (if different from email)"
  type        = string
  default     = ""
}

variable "tfc_variable_set_id" {
  description = "TFC variable set ID to apply to the workspace for OIDC authentication"
  type        = string
  default     = ""
}

variable "tfc_variable_set_name" {
  description = "TFC variable set name to apply to the workspace for OIDC authentication (alternative to ID)"
  type        = string
  default     = ""
}

variable "ado_secrets_variable_set_id" {
  description = "Optional TFC variable set ID that contains shared Azure DevOps secrets (e.g., AZDO_PERSONAL_ACCESS_TOKEN)"
  type        = string
  default     = ""
}

variable "ado_secrets_variable_set_name" {
  description = "Optional TFC variable set name that contains shared Azure DevOps secrets (alternative to ID)"
  type        = string
  default     = ""
}

variable "ado_automation_workspace" {
  description = "TFC workspace name for ado-automation (WS2) - used by WS3 to reference WS2 outputs"
  type        = string
  default     = "azure-lz-partner-subsB-01"
}

variable "azr_automation_workspace" {
  description = "TFC workspace name for azr-automation (WS1) - used by WS3 to reference WS1 outputs (optional)"
  type        = string
  default     = "azr-automation"
}

variable "azuredevops_pat" {
  description = "Azure DevOps Personal Access Token to inject into WS3 for azuredevops provider authentication (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_team_names" {
  description = "List of TFC team names to grant admin access to the workspace"
  type        = list(string)
  default     = []
}

variable "read_team_names" {
  description = "List of TFC team names to grant read access to the workspace"
  type        = list(string)
  default     = []
}

variable "config_directory" {
  description = "Directory containing partner YAML config files (passed from WS1 to WS3)"
  type        = string
  default     = "../../subscription-manifests/ps01"
}
