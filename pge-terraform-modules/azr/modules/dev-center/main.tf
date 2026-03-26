# Dev Center Module
# Creates Azure Dev Center and Dev Center project for managed DevOps pool governance
# Required for Azure Managed DevOps Pools to function

terraform {
  required_version = ">= 1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
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

# Dev Center is only available in limited regions
# See: https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box#supported-regions
# Using westus2 as default fallback since it's widely available and compliant with most policies
locals {
  dev_center_supported_regions = [
    "australiaeast", "brazilsouth", "canadacentral", "centralus", "francecentral",
    "polandcentral", "spaincentral", "uaenorth", "westeurope", "germanywestcentral",
    "italynorth", "japaneast", "japanwest", "uksouth", "eastus", "eastus2",
    "southafricanorth", "southcentralus", "southeastasia", "switzerlandnorth",
    "swedencentral", "westus2", "westus3", "centralindia", "eastasia", "northeurope", "koreacentral"
  ]
  # Use partner location if supported, otherwise fallback to westus2
  dev_center_location = contains(local.dev_center_supported_regions, lower(var.location)) ? var.location : "westus3"
}

# Create Dev Center resource (container for projects)
resource "azapi_resource" "dev_center" {
  type      = "Microsoft.DevCenter/devcenters@2025-02-01"
  name      = "devcenter-${var.partner_name}"
  parent_id = var.resource_group_id
  location  = local.dev_center_location # Use supported region

  body = {
    properties = {}
  }

  tags = var.tags

  timeouts {
    create = "45m"
    update = "30m"
    delete = "30m"
  }
}

# Create Dev Center Project (actual governance container for managed pools)
# Note: Projects are deployed in the resource group, not as children of Dev Center
# They reference the Dev Center via devCenterId property
# Project must be in same region as Dev Center
resource "azapi_resource" "dev_center_project" {
  type      = "Microsoft.DevCenter/projects@2025-02-01"
  name      = "SharedServices-Dev-Project"
  parent_id = var.resource_group_id
  location  = local.dev_center_location # Must match Dev Center location

  body = {
    properties = {
      description        = "Managed pool governance project"
      devCenterId        = azapi_resource.dev_center.id
      maxDevBoxesPerUser = 0
    }
  }


  timeouts {
    create = "45m"
    update = "30m"
    delete = "30m"
  }
  tags = merge(var.tags, local.module_tags)
}