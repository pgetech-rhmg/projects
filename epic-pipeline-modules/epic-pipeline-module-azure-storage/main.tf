resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_blob_public_access

  blob_properties {
    versioning_enabled = var.enable_versioning

    # azurerm requires days in 1..365, so a disabled policy must OMIT the block
    # entirely (a dynamic with an empty for_each) rather than pass days = 0,
    # which fails apply. Enabled -> one block with the configured retention.
    dynamic "delete_retention_policy" {
      for_each = var.enable_blob_soft_delete ? [1] : []
      content {
        days = var.blob_soft_delete_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.enable_container_soft_delete ? [1] : []
      content {
        days = var.container_soft_delete_days
      }
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
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.access_type
}

# Static website hosting (serves content from the implicit $web container).
# Enable for frontend SPA hosting; leave disabled for plain blob storage.
resource "azurerm_storage_account_static_website" "this" {
  count = var.static_website != null ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id
  index_document     = var.static_website.index_document
  error_404_document = var.static_website.error_404_document
}

# Deployer data-plane access. Uploading blobs (e.g. a SPA to $web) uses AAD/RBAC
# (`az storage blob upload-batch --auth-mode login`), which needs a data-plane
# role — CREATING the account (Contributor, control-plane) does NOT confer it.
# We deliberately use RBAC rather than shared account keys: keys are unscoped,
# non-auditable, full-account bearer credentials, whereas this grant is scoped,
# per-identity, and revocable. Opt-in (default off) so plain data accounts that
# nobody uploads to from the pipeline aren't over-granted; a static-site account
# turns it on. Grants to the DEPLOYING principal — for EPIC that's the same SPN
# that later runs the static deploy (same per-env service connection).
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "deployer_blob_contributor" {
  count = var.grant_deployer_blob_contributor ? 1 : 0

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
