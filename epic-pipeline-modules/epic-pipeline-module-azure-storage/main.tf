resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  min_tls_version           = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_blob_public_access

  blob_properties {
    versioning_enabled = var.enable_versioning

    delete_retention_policy {
      days = var.enable_blob_soft_delete ? var.blob_soft_delete_days : 0
    }

    container_delete_retention_policy {
      days = var.enable_container_soft_delete ? var.container_soft_delete_days : 0
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  for_each = { for c in var.containers : c.name => c }

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.access_type
}
