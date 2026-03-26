# ============================================================================
# Azure Managed DevOps Pool Module
# ============================================================================
# Creates Azure-managed agent pools with auto-scaling (no PAT required)
# Based on working Bicep template with Dev Center support

terraform {
  required_version = ">= 1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Create Azure Managed DevOps Pool using azapi (native Azure resource)
# Using 2025-09-20 API version (latest supported) with full configuration including Dev Center
resource "azapi_resource" "managed_pool" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-09-20"
  name      = var.pool_name
  parent_id = var.resource_group_id
  # Pool MUST be in the same region as the VNet it connects to
  location = var.location

  # Use UserAssigned managed identity (MI2 for service connections)
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  body = {
    properties = {
      # Azure DevOps organization configuration
      organizationProfile = {
        kind = "AzureDevOps"
        organizations = [
          {
            url         = var.ado_org_url
            projects    = var.ado_project_names # Empty list allows all projects
            parallelism = var.max_agents        # Must equal maximumConcurrency for the pool
            openAccess  = true
          }
        ]
        permissionProfile = {
          kind = "Inherit"
        }
      }

      # Link to Dev Center project (for governance and management)
      # Required by API - provides centralized pool management
      devCenterProjectResourceId = var.dev_center_project_id

      # Agent specification - stateless ephemeral agents
      agentProfile = {
        kind = "Stateless"
      }

      # Compute profile - VMSS with specific configuration
      fabricProfile = {
        kind = "Vmss"

        # VM SKU for agent machines
        sku = {
          name = var.agent_sku # e.g., "Standard_D2s_v3" or "Standard_F1"
        }

        # Agent OS images with aliases
        images = [
          {
            wellKnownImageName = replace(var.agent_image, "/latest", "") # Strip "/latest" if present
            aliases = [
              replace(var.agent_image, "/latest", "") # e.g., "ubuntu-24.04"
            ]
            buffer = "*" # Auto-scaling buffer
          }
        ]

        # OS configuration
        osProfile = {
          secretsManagementSettings = {
            observedCertificates = []
            keyExportable        = false
          }
          logonType = "Service"
        }

        # Storage configuration
        storageProfile = {
          osDiskStorageAccountType = "Standard"
          dataDisks                = []
        }

        # Network configuration - connect to VNet for private endpoint access
        networkProfile = var.subnet_id != null ? {
          subnetId = var.subnet_id
        } : null
      }

      # Maximum concurrent agents
      maximumConcurrency = var.max_agents
    }
  }

  tags = merge(var.tags, local.module_tags)

  # Ensure resource providers and managed identity are created first
  depends_on = [
    var.resource_providers_registered,
    var.managed_identity_id
  ]
}

# Data source to retrieve the Azure DevOps pool ID after creation
# Azure Managed Pools are automatically registered in ADO with the same name
data "azuredevops_agent_pool" "managed_pool" {
  name       = var.pool_name
  depends_on = [azapi_resource.managed_pool]
}