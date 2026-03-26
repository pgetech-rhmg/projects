/*
* # Azure DevOps Service Connections Module
* Terraform module which creates SAF2.0 ADO service connection for Partner subscription (using MI2) and GitHub (using OIDC or PAT)
*/

#  Filename    : azr/modules/azuredevops-serivce-connection/main.tf
#  Date        : 4 March 2026
#  Author      : CCOE
#  Description : api-gateway terraform module creates ADO service connections
#  Creates outbound ADO service connection to Azure (using MI2)
#  and inbound ADO service connection from GitHub (using SP1)


# Service Connection to Azure using Workload Identity Federation (OIDC - NO SECRETS)
# This is the most secure approach - uses federated identity credentials instead of PAT/credentials
# For OIDC, credentials are not required - TFC provides the token automatically
resource "azuredevops_serviceendpoint_azurerm" "azure_connection" {
  count                                  = var.create_azure_connection ? 1 : 0
  project_id                             = var.project_id
  service_endpoint_name                  = var.azure_connection_name
  description                            = var.azure_connection_description
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"

  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name

  credentials {
    serviceprincipalid = var.managed_identity_client_id
  }

  # IMPORTANT: create_before_destroy ensures new connection exists before old is deleted
  # This helps with the federated credential dependency issue
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# FEDERATED CREDENTIAL ON MI2 (Cross-Subscription via azapi)
# ============================================================================
# Automatically create federated credential on MI2 using the service connection's
# workload identity federation issuer and subject (computed by Azure DevOps).
# 
# Uses azapi_resource instead of azurerm_federated_identity_credential because:
# - azapi uses OIDC auth that works across subscriptions
# - azurerm provider is configured for platform subscription only
# - MI2 exists in the partner subscription
#
# The issuer and subject are computed by Azure DevOps after the service
# connection is created (Entra ID format, not legacy vstoken format).

resource "azapi_resource" "federated_credential" {
  count = var.create_azure_connection && var.create_federated_credential ? 1 : 0

  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31"
  name      = "fc-ado-sc-${replace(var.azure_connection_name, "/[^a-zA-Z0-9-]/", "-")}"
  parent_id = var.managed_identity_id

  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = azuredevops_serviceendpoint_azurerm.azure_connection[0].workload_identity_federation_issuer
      subject   = azuredevops_serviceendpoint_azurerm.azure_connection[0].workload_identity_federation_subject
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  # IMPORTANT: This ensures the federated credential is replaced when the service connection changes
  # and is deleted BEFORE the service connection is deleted (via replace_triggered_by)
  lifecycle {
    create_before_destroy = false # Delete old credential first, then create new
    replace_triggered_by = [
      azuredevops_serviceendpoint_azurerm.azure_connection[0].id
    ]
  }
}

# Grant all pipelines access to Azure service connection (optional)
resource "azuredevops_pipeline_authorization" "azure_connection_auth" {
  count       = var.create_azure_connection && var.authorize_all_pipelines ? 1 : 0
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_azurerm.azure_connection[0].id
  type        = "endpoint"

  # Wait for federated credential to be created before authorizing pipelines
  depends_on = [azapi_resource.federated_credential]
}

# Service Connection from GitHub (using OIDC - secure, no PAT required)
resource "azuredevops_serviceendpoint_github" "github_connection" {
  count                 = var.create_github_connection ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = var.github_connection_name
  description           = var.github_connection_description

  # Use OAuth/OIDC instead of PAT for security
  dynamic "auth_oauth" {
    for_each = var.create_github_oidc ? [1] : []
    content {
      oauth_configuration_id = var.github_oauth_config_id
    }
  }

  # Fallback to PAT if OIDC not configured (for backward compatibility)
  dynamic "auth_personal" {
    for_each = !var.create_github_oidc && var.github_pat != "" ? [1] : []
    content {
      personal_access_token = var.github_pat
    }
  }
}

# Grant all pipelines access to GitHub service connection (optional)
resource "azuredevops_pipeline_authorization" "github_connection_auth" {
  count       = var.create_github_connection && var.authorize_all_pipelines ? 1 : 0
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_github.github_connection[0].id
  type        = "endpoint"
}

# Alternative: GitHub App-based connection (more secure than PAT)
resource "azuredevops_serviceendpoint_github" "github_app_connection" {
  count                 = var.create_github_app_connection ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = var.github_app_connection_name
  description           = var.github_app_connection_description

  auth_oauth {
    oauth_configuration_id = var.github_oauth_config_id
  }
}

resource "azuredevops_pipeline_authorization" "github_app_connection_auth" {
  count       = var.create_github_app_connection && var.authorize_all_pipelines ? 1 : 0
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_github.github_app_connection[0].id
  type        = "endpoint"
}

# ============================================================================
# SONARQUBE SERVICE CONNECTION
# ============================================================================
# Creates SonarQube service connection for code quality analysis
# Uses token-based authentication (SonarQube project token)

resource "azuredevops_serviceendpoint_sonarqube" "sonarqube_connection" {
  count                 = var.create_sonarqube_connection ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = var.sonarqube_connection_name
  url                   = var.sonarqube_url
  token                 = var.sonarqube_token
  description           = "SonarQube connection for code quality analysis"
}

resource "azuredevops_pipeline_authorization" "sonarqube_connection_auth" {
  count       = var.create_sonarqube_connection && var.authorize_all_pipelines ? 1 : 0
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_sonarqube.sonarqube_connection[0].id
  type        = "endpoint"
}

# ============================================================================
# JFROG ARTIFACTORY SERVICE CONNECTION
# ============================================================================
# Creates JFrog Artifactory service connection for artifact management
# Uses token-based authentication (JFrog access token or API key)

resource "azuredevops_serviceendpoint_generic" "jfrog_connection" {
  count                 = var.create_jfrog_connection ? 1 : 0
  project_id            = var.project_id
  service_endpoint_name = var.jfrog_connection_name
  description           = "JFrog Artifactory connection for artifact management"
  server_url            = var.jfrog_url
  username              = var.jfrog_username
  password              = var.jfrog_access_token
}

resource "azuredevops_pipeline_authorization" "jfrog_connection_auth" {
  count       = var.create_jfrog_connection && var.authorize_all_pipelines ? 1 : 0
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_generic.jfrog_connection[0].id
  type        = "endpoint"
}

# Generic Service Connection (for custom integrations)
resource "azuredevops_serviceendpoint_generic" "custom_connection" {
  for_each              = var.custom_service_connections
  project_id            = var.project_id
  service_endpoint_name = each.value.name
  description           = each.value.description
  server_url            = each.value.server_url
  username              = each.value.username
  password              = each.value.password
}

# Authorize custom service connections for all pipelines
resource "azuredevops_pipeline_authorization" "custom_connection_auth" {
  for_each    = var.authorize_all_pipelines ? var.custom_service_connections : {}
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_generic.custom_connection[each.key].id
  type        = "endpoint"
}
