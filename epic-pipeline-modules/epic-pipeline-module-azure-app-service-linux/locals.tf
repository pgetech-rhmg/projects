locals {
  epic = {
      managed_by  = "EPIC"
      team        = "CCoE"
      contract    = "pge-epic-module-v1"
  }

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