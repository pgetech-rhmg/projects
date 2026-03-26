# ============================================================================
#  Azure DevOps Project Module
# ============================================================================
# Creates Azure DevOps projects with managed identity (MI2) for Azure connections
#
# Features: Boards, Repos, Pipelines, Test Plans, Artifacts
#
# Module: azr/modules/azuredevops-project
# Author: PGE
# Created: Mar 06, 2026
# ============================================================================

terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Create Azure DevOps Project
resource "azuredevops_project" "project" {
  name               = var.project_name
  description        = var.project_description
  visibility         = var.project_visibility
  version_control    = var.version_control
  work_item_template = var.work_item_template

  features = {
    "boards"       = var.enable_boards
    "repositories" = var.enable_repos
    "pipelines"    = var.enable_pipelines
    "testplans"    = var.enable_testplans
    "artifacts"    = var.enable_artifacts
  }
}



# Grant admin permissions to the Managed Identity (MI2) principal
# MI2 is the OIDC service principal used by ADO service connections
# This gives the OIDC connection full admin access internally without manual UI steps
resource "azuredevops_project_permissions" "mi2_admin" {
  count      = var.managed_identity_descriptor != "" ? 1 : 0
  project_id = azuredevops_project.project.id
  principal  = var.managed_identity_descriptor

  permissions = {
    "GENERIC_READ"  = "Allow"
    "GENERIC_WRITE" = "Allow"
    "DELETE"        = "Allow"
  }
}

# Note: Managed Identity (MI2) is now created in the parent module (main.tf)
# This allows the MI to be created in a dedicated resource group before ADO project creation

# NOTE: Group management via Terraform is not recommended for ADO projects
# due to conflicts with built-in groups (Project Administrators, Project Contributors, etc.)
# Instead, we grant permissions directly to principals (users, service principals) via
# azuredevops_project_permissions resource below.
# The MI2 service principal gets full admin permissions via the mi2_admin resource.

# Get the built-in Project Administrators group
data "azuredevops_group" "project_administrators" {
  project_id = azuredevops_project.project.id
  name       = "Project Administrators"
}

# Get the built-in Contributors group
data "azuredevops_group" "contributors" {
  project_id = azuredevops_project.project.id
  name       = "Contributors"
}

# Get the built-in Readers group
data "azuredevops_group" "readers" {
  project_id = azuredevops_project.project.id
  name       = "Readers"
}

# Get the built-in Project Valid Users group (default group for all users)
data "azuredevops_group" "project_valid_users" {
  project_id = azuredevops_project.project.id
  name       = "Project Valid Users"
}

# Add the Azure AD admin group to Project Administrators group
# This gives full admin access including Service Connections visibility
resource "azuredevops_group_membership" "admin_group_membership" {
  count = var.admin_group_descriptor != "" ? 1 : 0
  group = data.azuredevops_group.project_administrators.descriptor

  members = [
    var.admin_group_descriptor
  ]
}

# Grant Azure AD Admin Group project administrator permissions (backup)
# Note: Group membership above handles most admin access. This resource provides
# explicit permission grants. Reserved permissions removed to avoid system conflicts.
resource "azuredevops_project_permissions" "admin_group_permissions" {
  count      = var.admin_group_descriptor != "" ? 1 : 0
  project_id = azuredevops_project.project.id
  principal  = var.admin_group_descriptor # Azure AD group descriptor

  permissions = {
    "GENERIC_READ"  = "Allow"
    "GENERIC_WRITE" = "Allow"
    "DELETE"        = "Allow"
    "RENAME"        = "Allow"
  }

  depends_on = [azuredevops_group_membership.admin_group_membership]
}

# ========================================
# Per-Partner Security Groups from YAML
# ========================================

# Add Azure AD groups using group entitlements
# This resource automatically handles Azure AD group sync and permissions
# The origin_id format tells ADO to sync the group from Azure AD

# Add read_write_groups as Contributors
resource "azuredevops_group_entitlement" "read_write_groups" {
  for_each = toset(var.read_write_groups)

  # Origin format for Azure AD groups
  origin_id = each.value
  origin    = "aad"

  # Note: We can't directly assign to Contributors group via entitlement
  # We'll use a different approach - azuredevops_group resource with members
}

# Add read_only_groups as Readers  
resource "azuredevops_group_entitlement" "read_only_groups" {
  for_each = toset(var.read_only_groups)

  origin_id = each.value
  origin    = "aad"
}

# After entitlements are created, add the groups to project groups
# We need to use project-level group membership after the groups are synced

# Add synced read_write groups to Contributors
resource "azuredevops_group_membership" "read_write_groups" {
  count = length(var.read_write_groups) > 0 ? 1 : 0
  group = data.azuredevops_group.contributors.descriptor

  # Use the descriptor from the entitlement resource
  # The descriptor is available after the group is synced
  members = [
    for group_id in var.read_write_groups :
    azuredevops_group_entitlement.read_write_groups[group_id].descriptor
  ]

  depends_on = [azuredevops_group_entitlement.read_write_groups]
}

# Add synced read_only groups to Readers
resource "azuredevops_group_membership" "read_only_groups" {
  count = length(var.read_only_groups) > 0 ? 1 : 0
  group = data.azuredevops_group.readers.descriptor

  members = [
    for group_id in var.read_only_groups :
    azuredevops_group_entitlement.read_only_groups[group_id].descriptor
  ]

  depends_on = [azuredevops_group_entitlement.read_only_groups]
}

# Add the global readers group descriptor to the project Readers group
# This is typically the "AZR DevOps" group that provides default read access
resource "azuredevops_group_membership" "global_readers" {
  count = var.readers_group_descriptor != "" ? 1 : 0
  group = data.azuredevops_group.project_valid_users.descriptor

  members = [
    var.readers_group_descriptor
  ]

  lifecycle {
    ignore_changes = [members]
  }
}























# Add the Azure AD group to Readers group (read-only access)
resource "azuredevops_group_membership" "readers_group_membership" {
  count = var.readers_group_descriptor != "" ? 1 : 0
  group = data.azuredevops_group.readers.descriptor

  members = [
    var.readers_group_descriptor
  ]

  lifecycle {
    ignore_changes = all
  }

}
