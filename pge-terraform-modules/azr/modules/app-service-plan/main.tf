# ============================================================================
# Azure App Service Plan Module
# ============================================================================
# Creates Azure App Service Plans for hosting web apps and API apps.
#
# Features:
# - Support for Windows and Linux operating systems
# - Optional App Service Environment (ASE) integration
# - Configurable SKU, worker count, and per-site scaling
# - Fully parameterized, partner-safe inputs
#
# Module: azr/modules/app-service-plan
# Author: PG&E
# Created: Mar 11, 2026
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
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}


module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = var.os_type
  sku_name = var.sku_name

  # Optional: Run on ASE if provided
  app_service_environment_id = var.ase_id != "" ? var.ase_id : null

  # Configuration
  worker_count             = var.worker_count
  per_site_scaling_enabled = var.per_site_scaling_enabled

  tags = merge(
    var.tags, local.module_tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "app_service_plan"
    }
  )
}
