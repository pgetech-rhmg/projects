locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  plan_name = coalesce(var.service_plan_name, "${var.function_app_name}-plan")

  default_runtime_versions = {
    node   = "20"
    dotnet = "10.0"
    python = "3.11"
  }

  effective_runtime_version = coalesce(var.runtime_version, local.default_runtime_versions[var.runtime])

  key_vault_app_settings = {
    for key, secret_uri in var.key_vault_secret_refs :
    key => "@Microsoft.KeyVault(SecretUri=${secret_uri})"
  }

  merged_app_settings = merge(
    var.app_settings,
    local.key_vault_app_settings
  )
}
