############################################
# Resource Group
############################################

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.azure_region
  tags     = var.tags
}

############################################
# Storage Account — Shared Terraform State
############################################

resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"

  min_tls_version           = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

############################################
# Blob Container — tfstate
############################################

resource "azurerm_storage_container" "tfstate" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.this.id
}

############################################
# Lock — Prevent accidental deletion
############################################

resource "azurerm_management_lock" "this" {
  name       = "epic-terraform-state-lock"
  scope      = azurerm_storage_account.this.id
  lock_level = "CanNotDelete"
  notes      = "Protects EPIC shared Terraform state — do not remove"
}
