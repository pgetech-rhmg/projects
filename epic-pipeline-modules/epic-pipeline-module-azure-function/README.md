# EPIC Azure Function Module

## Overview

Provisions an Azure Linux Function App and its backing App Service Plan for use as an EPIC deploy target on Azure. The runtime stack (`node`, `dotnet`, or `python`) is selected via `runtime`, and the module exposes a system-assigned managed identity for downstream resources (Key Vault, Storage, etc.).

This module is consumed from an application's `.infra/` folder. EPIC reads `.pipeline/epic.json` to detect Azure (`cloud.azureSubscriptionId`), runs Terraform from `.infra/`, and captures `outputs.tf` as the `terraform-outputs` artifact for downstream stages.

---

## Resources

- `azurerm_service_plan` (Linux)
- `azurerm_linux_function_app`
- System-assigned managed identity on the Function App

Defaults: HTTPS-only enforced, Functions runtime `~4`, plan name derived as `<function_app_name>-plan` when `service_plan_name` is not set.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group |
| `azure_region` | `string` | Azure region |
| `function_app_name` | `string` | Name of the Function App |
| `storage_account_name` | `string` | Storage account for Function App state |
| `storage_account_access_key` | `string` (sensitive) | Storage account access key |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `service_plan_name` | `string` | `null` | Name of the App Service Plan. If `null`, derived as `<function_app_name>-plan` |
| `sku_name` | `string` | `"Y1"` | App Service Plan SKU. `Y1` = Consumption, `EP1`/`EP2`/`EP3` = Premium, `B1`/`S1` = Dedicated |
| `runtime` | `string` | `"node"` | One of `node`, `dotnet`, `python` |
| `runtime_version` | `string` | `null` | Runtime version. If `null`, uses per-runtime default (`node` 20, `dotnet` 10.0, `python` 3.11) |
| `app_settings` | `map(string)` | `{}` | Application settings (environment variables) |
| `key_vault_secret_refs` | `map(string)` | `{}` | App settings mapped to Key Vault Secret URIs; resolved at runtime via managed identity |
| `https_only` | `bool` | `true` | Enforce HTTPS-only traffic |
| `functions_extension_version` | `string` | `"~4"` | Azure Functions runtime version |
| `tags` | `map(string)` | `{}` | Resource tags |

---

## Outputs

| Name | Description |
|------|-------------|
| `function_app_id` | Function App resource ID |
| `function_app_name` | Function App name |
| `default_hostname` | Default Function App hostname |
| `service_plan_id` | App Service Plan ID |
| `principal_id` | Managed identity principal ID |

---

## Usage in a Terraform project

In an application's `.infra/main.tf`:

```hcl
module "function_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-function.git?ref=main"

  resource_group_name = "rg-my-fn-dev"
  azure_region        = "westus2"

  function_app_name          = "fn-my-app-dev"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.primary_access_key

  runtime         = "python"
  runtime_version = "3.11"
  sku_name        = "Y1"

  app_settings = {
    APP_ENV = "dev"
  }

  key_vault_secret_refs = {
    DATABASE_URL = module.key_vault.secret_uris["database-url"]
  }

  tags = {
    application = "my-app"
    environment = "dev"
  }
}
```

In `.infra/outputs.tf`, re-export the values needed by downstream stages:

```hcl
output "function_app_name" {
  value = module.function_app.function_app_name
}

output "resource_group_name" {
  value = "rg-my-fn-dev"
}

output "default_hostname" {
  value = module.function_app.default_hostname
}
```

---

## Usage from another module

```hcl
module "function_app" {
  source = "../epic-pipeline-module-azure-function"

  resource_group_name = azurerm_resource_group.this.name
  azure_region        = azurerm_resource_group.this.location

  function_app_name          = local.function_app_name
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  runtime  = "dotnet"
  sku_name = "EP1"

  tags = local.tags
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| `terraform` | `>= 1.5.0` |
| `azurerm` | `~> 3.100` |

---

## Notes

- The plan is created as Linux (`os_type = "Linux"`); Windows Function Apps are out of scope.
- For `dotnet`, the isolated worker model is enabled (`use_dotnet_isolated_runtime = true`).
- `key_vault_secret_refs` values must be full Secret URIs (e.g. `https://<vault>.vault.azure.net/secrets/<name>/<version>`); they are wrapped as `@Microsoft.KeyVault(SecretUri=...)` and merged into `app_settings`. The module does not grant Key Vault access — wire RBAC or access policies separately using `principal_id`.
- Consumption plans (`Y1`) require a paired storage account; pass it via `storage_account_name` / `storage_account_access_key`.
