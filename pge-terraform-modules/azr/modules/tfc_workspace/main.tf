# ============================================================================
# Terraform Cloud Workspace Module
# ============================================================================
# Creates and configures a Terraform Cloud workspace with team access,
# variable set attachments, OIDC authentication, and optional Azure DevOps
# provider integration.
#
# Features:
# - Workspace creation with project association and execution mode settings
# - Team access management (admin/read) including temporary team creation
# - OIDC variable set attachment for Azure authentication
# - Optional Azure DevOps secrets variable set (shared PAT/env vars)
# - Azure authentication via Managed Identity (OIDC)
# - Scoped Azure DevOps PAT support for WS3 provider authentication
# - Partner configuration variable ingestion
# - Standardized tagging and workspace metadata injection
#
# Module: azr/modules/tfc_workspace
# Author: PG&E
# Created: Mar 04, 2026
# ============================================================================

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.53"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

provider "tfe" {}

data "azurerm_client_config" "current" {}

# Create TFC workspace
resource "tfe_workspace" "partner_workspace" {
  name         = var.workspace_name
  organization = var.tfc_organization
  description  = "Partner workspace for ${var.partner_name} - ${var.partner_config.environment} environment"
  project_id   = var.tfc_project_id != "" ? var.tfc_project_id : null

  auto_apply        = false
  queue_all_runs    = false
  terraform_version = ">= 1.0"
  working_directory = var.vcs_working_directory
  force_delete      = true # Allow deletion even if workspace has managed resources

  # Configure VCS repo if oauth_token_id is provided
  dynamic "vcs_repo" {
    for_each = var.oauth_token_id != "" ? [1] : []

    content {
      identifier     = "${var.github_organization}/${var.github_repo}"
      oauth_token_id = var.oauth_token_id # Use existing OAuth token from variable set
      branch         = var.github_branch
    }
  }

  tag_names = [
    "partner:${var.partner_name}",
    "environment:${var.partner_config.environment}",
    "managed-by:automation-a"
  ]
}

# Configure workspace execution settings (replaces deprecated execution_mode attribute)
resource "tfe_workspace_settings" "partner_workspace" {
  workspace_id = tfe_workspace.partner_workspace.id

  execution_mode = "remote"
}

# ============================================================================
# TEAM ACCESS - Grant admin/read access to specified teams
# ============================================================================

# Look up admin teams by name
data "tfe_team" "admin_teams" {
  for_each     = toset(var.admin_team_names)
  name         = each.value
  organization = var.tfc_organization
}

# Grant admin access to specified teams
resource "tfe_team_access" "admin_access" {
  for_each     = toset(var.admin_team_names)
  access       = "admin"
  team_id      = data.tfe_team.admin_teams[each.key].id
  workspace_id = tfe_workspace.partner_workspace.id

  lifecycle {
    ignore_changes = [access, team_id]
  }
}

# Look up read teams by name
data "tfe_team" "read_teams" {
  for_each     = toset(var.read_team_names)
  name         = each.value
  organization = var.tfc_organization
}

# Grant read access to specified teams
resource "tfe_team_access" "read_access" {
  for_each     = toset(var.read_team_names)
  access       = "read"
  team_id      = data.tfe_team.read_teams[each.key].id
  workspace_id = tfe_workspace.partner_workspace.id

  lifecycle {
    ignore_changes = [access, team_id]
  }
}

# Apply OIDC variable set to workspace (if provided)
data "tfe_variable_set" "oidc_variable_set" {
  count = var.tfc_variable_set_name != "" ? 1 : 0

  name         = var.tfc_variable_set_name
  organization = var.tfc_organization
}

resource "tfe_workspace_variable_set" "oidc_variable_set" {
  count = var.tfc_variable_set_id != "" || var.tfc_variable_set_name != "" ? 1 : 0

  variable_set_id = var.tfc_variable_set_id != "" ? var.tfc_variable_set_id : data.tfe_variable_set.oidc_variable_set[0].id
  workspace_id    = tfe_workspace.partner_workspace.id
  lifecycle {
    ignore_changes = [workspace_id, variable_set_id]
  }
}

# Attach optional Azure DevOps secrets variable set (contains shared PAT/env vars)
data "tfe_variable_set" "ado_secrets_variable_set" {
  count = var.ado_secrets_variable_set_name != "" ? 1 : 0

  name         = var.ado_secrets_variable_set_name
  organization = var.tfc_organization
}

resource "tfe_workspace_variable_set" "ado_secrets_variable_set" {
  count = var.ado_secrets_variable_set_id != "" || var.ado_secrets_variable_set_name != "" ? 1 : 0

  variable_set_id = var.ado_secrets_variable_set_id != "" ? var.ado_secrets_variable_set_id : data.tfe_variable_set.ado_secrets_variable_set[0].id
  workspace_id    = tfe_workspace.partner_workspace.id
}

# OIDC configuration for WS3
resource "tfe_variable" "arm_use_oidc" {
  key          = "ARM_USE_OIDC"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Enable OIDC authentication for WS3"
}

# Azure credentials using Managed Identity (OIDC)
# NOTE: ARM_* environment variables removed - provided by OIDC variable set
# TFC automatically provides TFC_AZURE_RUN_* runtime variables

# Terraform variables from partner config
resource "tfe_variable" "config_directory" {
  key          = "config_directory"
  value        = var.config_directory
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Directory containing partner YAML config files"
}

resource "tfe_variable" "partner_name" {
  key          = "partner_name"
  value        = var.partner_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Partner name"
}

resource "tfe_variable" "environment" {
  key          = "environment"
  value        = var.partner_config.environment
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Environment name"
}

resource "tfe_variable" "resource_group_name" {
  key          = "resource_group_name"
  value        = var.resource_group_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Resource Group name"
}

resource "tfe_variable" "network_resource_group_name" {
  count        = var.network_resource_group_name != "" ? 1 : 0
  key          = "network_resource_group_name"
  value        = var.network_resource_group_name != "" ? var.network_resource_group_name : var.resource_group_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Resource group containing WS1 network resources"
}

resource "tfe_variable" "compute_resource_group_name" {
  key          = "compute_resource_group_name"
  value        = var.compute_resource_group_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Resource group for WS3 application resources"
}

resource "tfe_variable" "data_resource_group_name" {
  count        = var.data_resource_group_name != "" ? 1 : 0
  key          = "data_resource_group_name"
  value        = var.data_resource_group_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Resource group for WS3 data resources"
}

resource "tfe_variable" "vnet_name" {
  key          = "vnet_name"
  value        = var.vnet_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "VNet name"
}

resource "tfe_variable" "app_id" {
  key          = "app_id"
  value        = try(var.partner_config.tags.AppID, var.partner_name)
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Application ID tag"
}

# Managed Identity variables (for App Service and resource RBAC assignments)
resource "tfe_variable" "managed_identity_id" {
  key          = "managed_identity_id"
  value        = var.managed_identity_id
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Managed Identity resource ID for attaching to App Service"
}

resource "tfe_variable" "managed_identity_client_id" {
  key          = "managed_identity_client_id"
  value        = var.managed_identity_client_id
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Managed Identity client ID for SQL Active Directory Default authentication"
}

resource "tfe_variable" "managed_identity_principal_id" {
  key          = "managed_identity_principal_id"
  value        = var.managed_identity_principal_id
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Managed Identity principal ID (Object ID) for RBAC assignments"
}

resource "tfe_variable" "managed_identity_name" {
  key          = "managed_identity_name"
  value        = var.managed_identity_name
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Managed Identity name"
}

# GitHub configuration variables
resource "tfe_variable" "github_org" {
  key          = "github_organization"
  value        = var.github_organization
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "GitHub organization name"
}

resource "tfe_variable" "github_repository" {
  key          = "github_repository"
  value        = var.github_repo
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "GitHub repository name"
}

# Child Automation (WS3) specific variables
resource "tfe_variable" "partner_subscription_id" {
  key          = "partner_subscription_id"
  value        = var.partner_subscription_id
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Partner Azure subscription ID for child-automation deployment"
}

resource "tfe_variable" "azuredevops_org_url" {
  key          = "azuredevops_org_url"
  value        = var.azuredevops_org_url
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "Azure DevOps organization URL for pipeline creation"
}

resource "tfe_variable" "github_service_connection_id" {
  key          = "github_service_connection_id"
  value        = var.github_service_connection_id
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "GitHub service connection ID from WS2 (ado-automation) for pipeline authorization"
}

# TFC Organization and workspace references for WS3 data sources
resource "tfe_variable" "tfc_organization" {
  key          = "tfc_organization"
  value        = var.tfc_organization
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "TFC organization name (used by WS3 tfe_outputs data sources)"
}

resource "tfe_variable" "ado_automation_workspace" {
  key          = "ado_automation_workspace"
  value        = var.ado_automation_workspace
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  description  = "TFC workspace name for ado-automation (WS2) - used by WS3 to reference WS2 outputs"
}

# Azure DevOps PAT for provider authentication (only for WS3)
# If empty, the provider will attempt OIDC/MSI authentication
resource "tfe_variable" "azuredevops_personal_access_token" {
  count        = var.azuredevops_pat != "" ? 1 : 0
  key          = "azuredevops_personal_access_token"
  value        = var.azuredevops_pat
  category     = "terraform"
  workspace_id = tfe_workspace.partner_workspace.id
  sensitive    = true
  description  = "Azure DevOps Personal Access Token for azuredevops provider authentication"
}

# Provide AZDO_PERSONAL_ACCESS_TOKEN env var directly to workspace when no shared variable set is attached
resource "tfe_variable" "azuredevops_pat_env" {
  count = var.azuredevops_pat != "" && var.ado_secrets_variable_set_id == "" && var.ado_secrets_variable_set_name == "" ? 1 : 0

  key          = "AZDO_PERSONAL_ACCESS_TOKEN"
  value        = var.azuredevops_pat
  category     = "env"
  workspace_id = tfe_workspace.partner_workspace.id
  sensitive    = true
  description  = "Azure DevOps PAT injected as env var for azuredevops provider"
}

# NOTE: VCS configuration happens during workspace creation via dynamic "vcs_repo" block above
# Existing workspaces cannot have VCS added via Terraform - requires deletion and recreation

# Grant team Run permissions on workspace (optional)
resource "tfe_team_access" "workspace_access" {
  count        = var.team_name != "" ? 1 : 0
  team_id      = data.tfe_team.workspace_team[0].id
  workspace_id = tfe_workspace.partner_workspace.id

  permissions {
    runs              = "apply"
    variables         = "read"
    state_versions    = "read-outputs"
    workspace_locking = "false"
    run_tasks         = "false"
    sentinel_mocks    = "none"
  }
}

# Data source to look up team by name
data "tfe_team" "workspace_team" {
  count        = var.team_name != "" ? 1 : 0
  name         = var.team_name
  organization = var.tfc_organization
}

# Grant user via team membership - create a single-member team for direct user access
# Note: TFE doesn't support direct user workspace access; use team-based access instead
# User must be added to team manually in TFC UI, then this grants the team workspace access
resource "tfe_team_access" "user_team_access" {
  count        = var.user_email != "" && var.team_name == "" ? 1 : 0
  team_id      = tfe_team.user_team[0].id
  workspace_id = tfe_workspace.partner_workspace.id

  permissions {
    runs              = "apply"
    variables         = "read"
    state_versions    = "read-outputs"
    workspace_locking = "false"
    run_tasks         = "false"
    sentinel_mocks    = "none"
  }
}

# Create a temporary team for the user (if user_email specified but no team)
# This team can be used to grant workspace access
resource "tfe_team" "user_team" {
  count        = var.user_email != "" && var.team_name == "" ? 1 : 0
  name         = "${var.workspace_name}-user-access"
  organization = var.tfc_organization
}

# Add user to the team (automatically grant team membership)
resource "tfe_team_member" "user_member" {
  count    = var.user_email != "" && var.team_name == "" ? 1 : 0
  team_id  = tfe_team.user_team[0].id
  username = var.tfc_username != "" ? var.tfc_username : var.user_email
}

