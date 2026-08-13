data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = var.sku_name

  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  rbac_authorization_enabled = var.enable_rbac_authorization

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

# On an RBAC-authorization vault, CREATING the vault (control-plane, via
# Contributor) is separate from WRITING secrets (data-plane, requires a
# "Key Vault Secrets Officer" role). The deploying principal has the former but
# not the latter, so azurerm_key_vault_secret would 403 with ForbiddenByRbac /
# "Assignment: (not found)". When this module both manages secrets AND the vault
# is RBAC-authorized, self-grant the deployer Secrets Officer so it can write
# them. Skipped for access-policy vaults (rbac disabled) and when there are no
# secrets to write. Opt-out via grant_deployer_secrets_officer for environments
# that assign the role out of band.
locals {
  # The deployer needs data-plane write access whenever this module writes ANY
  # secret — fully-managed (var.secrets) OR seeded placeholders (var.seed_secrets).
  writes_any_secret             = length(var.secrets) > 0 || length(var.seed_secrets) > 0
  manage_deployer_secret_access = var.enable_rbac_authorization && local.writes_any_secret && var.grant_deployer_secrets_officer
}

resource "azurerm_role_assignment" "deployer_secrets_officer" {
  count = local.manage_deployer_secret_access ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# RBAC is eventually consistent — a freshly created role assignment is not
# immediately effective on the data plane, so writing secrets right after can
# still 403. Wait for propagation before the secret writes.
resource "time_sleep" "wait_for_secrets_officer" {
  count = local.manage_deployer_secret_access ? 1 : 0

  create_duration = var.secrets_officer_propagation_duration
  depends_on      = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_key_vault_secret" "this" {
  # var.secrets is sensitive (its VALUES are secret), and Terraform forbids a
  # sensitive value as for_each (keys would surface as instance addresses). The
  # secret NAMES are not sensitive, so iterate over the non-sensitive key set
  # and look each value back up from the sensitive map — keys drive for_each,
  # values stay protected in plan/logs.
  for_each = nonsensitive(toset(keys(var.secrets)))

  name         = each.key
  value        = var.secrets[each.key]
  key_vault_id = azurerm_key_vault.this.id

  # Ensure the deployer's Secrets Officer grant exists and has propagated before
  # attempting to write (no-op when the grant is disabled/not applicable).
  depends_on = [time_sleep.wait_for_secrets_officer]
}

# Seeded (hand-loaded) secrets — breaks the first-run chicken-and-egg where a
# dependent (e.g. a Container App) references a secret by URI that nothing has
# created yet, so its revision can't provision on a clean deploy. This SEEDS
# each such secret with a placeholder so dependents provision, then IGNORES the
# value forever after (lifecycle ignore_changes) so the real value an operator
# sets in Key Vault post-deploy is never clobbered on subsequent applies.
# Terraform owns existence, NOT the value. Keys are non-sensitive names; the
# placeholder is intentionally non-secret. Use var.secrets instead for secrets
# Terraform should remain the source of truth for (db passwords, conn strings).
resource "azurerm_key_vault_secret" "seed" {
  for_each = toset(var.seed_secrets)

  name         = each.key
  value        = var.seed_secret_placeholder
  key_vault_id = azurerm_key_vault.this.id

  # Existence is managed; the value is not. An operator (or another pipeline)
  # overwrites the placeholder with the real secret after the deploy, and later
  # applies must not revert it.
  lifecycle {
    ignore_changes = [value]
  }

  depends_on = [time_sleep.wait_for_secrets_officer]
}
