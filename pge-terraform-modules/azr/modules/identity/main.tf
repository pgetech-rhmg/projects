/*
 * # Azure Managed Identity module.
 * Terraform module which creates Azure User-Assigned Managed Identity with federated credentials.
*/

#
# Filename    : azr/modules/identity/main.tf
# Date        : 09 March 2026
# Author      : PGE
# Description : Managed Identity module main
#               Creates User-Assigned Managed Identity with federated credentials
#               for Terraform Cloud and GitHub Actions authentication.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Create Managed Identity using azapi_resource
resource "azapi_resource" "mi" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  name      = "mi-terraform-${var.partner_name}-${var.partner_config.environment}"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  body = {}

  tags = local.module_tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Federated credential for Terraform Cloud using azapi
resource "azapi_resource" "tfc" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31"
  name      = "fc-tfc-${var.tfc_workspace_name}"
  parent_id = azapi_resource.mi.id

  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = "https://app.terraform.io"
      subject   = "organization:${var.tfc_organization}:project:*:workspace:${var.tfc_workspace_name}:run_phase:*"
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

# Federated credential for GitHub Actions using azapi
# NOTE: Added depends_on to prevent concurrent writes (Azure API limitation)
# This single credential supports all GitHub Actions workflows (dev, staging, prod, etc.)
# Subject covers: repo:org/repo:ref:refs/heads/* (all branches)
resource "azapi_resource" "github" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31"
  name      = "fc-github-${var.github_repo}"
  parent_id = azapi_resource.mi.id

  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:${var.github_organization}/${var.github_repo}:ref:refs/heads/main"
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [azapi_resource.tfc]
}

# Assign Contributor role to Managed Identity at subscription scope
resource "azurerm_role_assignment" "contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azapi_resource.mi.output.properties.principalId
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

# Assign additional roles if specified in partner config
# Only processes subscription-scoped roles, skips Contributor (already assigned above)
# Resource-scoped roles (storage_account, key_vault) should be handled by their respective modules
resource "azurerm_role_assignment" "additional_roles" {
  for_each = try(
    {
      for role in var.partner_config.security.rbac_roles :
      role.name => role
      if role.scope == "subscription" && role.name != "Contributor"
    },
    {}
  )

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = each.value.name
  principal_id         = azapi_resource.mi.output.properties.principalId
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

# ============================================================================
# AZURE DEVOPS FEDERATED CREDENTIAL - MOVED TO WS2
# ============================================================================
# The federated credential for Azure DevOps service connections is now created
# in WS2 (ado-automation) AFTER the service connection is created.
# 
# This is because:
# 1. Azure DevOps uses Entra ID issuer format with unpredictable subjects
# 2. The subject is only known after the service connection is created
# 3. WS2 uses azapi to create the credential cross-subscription
#
# See: terraform/ado-automation/modules/azuredevops-service-connections/main.tf
# ============================================================================