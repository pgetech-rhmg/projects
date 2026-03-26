# ============================================================================
# Azure Storage Account Module
# ============================================================================
# Creates Azure Storage Accounts with blob containers, file shares,
# and optional private endpoints for blob and file services.
#
# Features:
# - Data plane creation via AzAPI to avoid RBAC propagation delays
# - Fully parameterized, partner-safe inputs
#
# Module: azr/modules/storage_account
# Author: PG&E
# Created: Mar 03, 2026
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


# Storage Account
resource "azurerm_storage_account" "storage" {
  name                            = lower(replace(var.storage_account_name, "-", ""))
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  min_tls_version                 = var.min_tls_version
  https_traffic_only_enabled      = var.enable_https_traffic_only
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public

  # Network rules (optional)
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  # Blob properties
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = merge(
    var.tags, local.module_tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "storage-account"
    }
  )
}

# Blob Containers - using azapi to avoid data plane auth issues
resource "azapi_resource" "containers" {
  for_each = { for c in var.blob_containers : c.name => c }

  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01"
  name      = each.value.name
  parent_id = "${azurerm_storage_account.storage.id}/blobServices/default"

  body = {
    properties = {
      publicAccess = each.value.container_access_type == "private" ? "None" : (
        each.value.container_access_type == "blob" ? "Blob" : "Container"
      )
    }
  }
}

# File Shares - using azapi to avoid data plane auth issues
resource "azapi_resource" "shares" {
  for_each = { for s in var.file_shares : s.name => s }

  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01"
  name      = each.value.name
  parent_id = "${azurerm_storage_account.storage.id}/fileServices/default"

  body = {
    properties = {
      shareQuota = each.value.quota
    }
  }
}

# Private Endpoint for Blob (optional)
resource "azurerm_private_endpoint" "blob" {
  count = var.enable_private_endpoint && var.private_endpoint_subnet_id != "" ? 1 : 0

  name                = "pe-${var.storage_account_name}-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-blob"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids.blob != "" ? [1] : []
    content {
      name                 = "pdz-${var.storage_account_name}-blob"
      private_dns_zone_ids = [var.private_dns_zone_ids.blob]
    }
  }

  tags = var.tags
}

# Private Endpoint for File (optional)
resource "azurerm_private_endpoint" "file" {
  count = var.enable_private_endpoint && var.private_endpoint_subnet_id != "" && length(var.file_shares) > 0 ? 1 : 0

  name                = "pe-${var.storage_account_name}-file"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-file"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids.file != "" ? [1] : []
    content {
      name                 = "pdz-${var.storage_account_name}-file"
      private_dns_zone_ids = [var.private_dns_zone_ids.file]
    }
  }

  tags = var.tags
}
