locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  # ── Runtime version defaults ──────────────────────────────────────────────
  default_runtime_versions = {
    node   = "22-lts"
    dotnet = "10.0"
    python = "3.11"
    java   = "17"
    php    = "8.3"
  }

  effective_runtime_version = coalesce(var.runtime_version, local.default_runtime_versions[var.runtime])

  # ── OS detection ──────────────────────────────────────────────────────────
  is_linux   = var.os_type == "Linux"
  is_windows = var.os_type == "Windows"

  # ── SKU-aware defaults ────────────────────────────────────────────────────
  # F1 and D1 (free/shared) don't support always_on
  supports_always_on = !contains(["F1", "D1"], var.sku_name)

  # ── Key Vault integration ─────────────────────────────────────────────────
  key_vault_app_settings = {
    for key, secret_uri in var.key_vault_secret_refs :
    key => "@Microsoft.KeyVault(SecretUri=${secret_uri})"
  }

  merged_app_settings = merge(
    {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    },
    var.app_settings,
    local.key_vault_app_settings
  )
}
