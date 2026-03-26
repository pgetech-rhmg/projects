/*
 * # Azure Cosmos DB module
*/
#  Filename    : azr/modules/cosmos-db/main.tf
#  Date        : 24 Feb 2026
#  Author      : PG&E
#  Description : Azure Cosmos DB module for creating and managing Cosmos DB accounts, databases, and containers with encryption and backup configurations.

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Pulls workspace information from Terraform Cloud
# This module retrieves the current workspace name and ID for tracking and tagging purposes
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Creates an Azure Cosmos DB account with the following configurations:
# - GlobalDocumentDB kind for SQL API support
# - Private network access only (public access disabled)
# - RBAC-based authentication (local authentication disabled)
# - Customer-managed encryption key support via Key Vault
# - Multi-region write capability (for provisioned mode)
# - Periodic backup with configurable intervals and retention
# - Serverless or provisioned capacity modes
# - Consistent tagging and lifecycle management

resource "azurerm_cosmosdb_account" "cosmos" {
  name                               = var.name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  offer_type                         = "Standard"
  kind                               = "GlobalDocumentDB"
  public_network_access_enabled      = false
  access_key_metadata_writes_enabled = false
  multiple_write_locations_enabled   = var.capacity_mode == "serverless" ? false : true
  key_vault_key_id                   = var.key_vault_key_id != "" ? var.key_vault_key_id : null


  # Enable RBAC for data plane operations
  local_authentication_disabled = true

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? 300 : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? 100000 : null
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }


  backup {
    type                = "Periodic"
    interval_in_minutes = var.backup_interval_in_minutes
    retention_in_hours  = var.backup_retention_interval_in_hours
    storage_redundancy  = var.backup_storage_redundancy
  }

  dynamic "capabilities" {
    for_each = var.capacity_mode == "serverless" ? ["EnableServerless"] : []
    content {
      name = capabilities.value
    }
  }

  tags = merge(
  var.tags, local.module_tags)

  # Prevent accidental deletion for non-development workloads
  lifecycle {
    prevent_destroy = false
  }
}

# Creates a Cosmos DB SQL database within the Cosmos DB account
# This resource is only created when api_type is set to "sql"
resource "azurerm_cosmosdb_sql_database" "database" {
  count               = var.api_type == "sql" ? 1 : 0
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

# Creates a Cosmos DB SQL container within the database
# This resource is only created when api_type is set to "sql"
# - Configures partition key for data distribution
# - Supports autoscale throughput for provisioned capacity mode
# - Serverless mode does not support manual throughput settings
resource "azurerm_cosmosdb_sql_container" "container" {
  count                 = var.api_type == "sql" ? 1 : 0
  name                  = var.container_name
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.database[0].name
  partition_key_paths   = [var.partition_key]
  partition_key_version = 1

  # Serverless doesn't support manual throughput settings
  dynamic "autoscale_settings" {
    for_each = var.capacity_mode == "provisioned" ? [1] : []
    content {
      max_throughput = var.max_throughput
    }
  }

  # Lifecycle management
  lifecycle {
    prevent_destroy = false
  }
}
