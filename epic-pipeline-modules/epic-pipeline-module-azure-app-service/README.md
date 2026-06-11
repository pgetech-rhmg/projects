# EPIC Azure App Service Module

## Overview

Provisions an Azure App Service Plan and a single App Service (Linux or Windows) as the EPIC deploy target on Azure. The App Service is runtime-agnostic at the infrastructure level — `runtime` selects the application stack (`node`, `dotnet`, `python`, `java`, `php`) and EPIC's deploy stage publishes the build via `az webapp deploy --type zip`.

This module is consumed from an application's `.infra/` folder. EPIC reads `.pipeline/epic.json` to detect Azure (`cloud.azureSubscriptionId`), runs Terraform from `.infra/`, captures `outputs.tf` as the `terraform-outputs` artifact, and the deploy stage resolves the App Service target from those outputs.

Per the engine docs, the deploy stage looks for `app_service_name` and `resource_group_name` in `terraform-outputs`. This module emits `app_service_name`; `resource_group_name` is an input here, so the consuming `.infra/outputs.tf` must re-export it (see Usage in a Terraform project).

---

## Resources

- `azurerm_service_plan`
- `azurerm_linux_web_app` (when `os_type = "Linux"`)
- `azurerm_windows_web_app` (when `os_type = "Windows"`)
- System-assigned managed identity on the web app

Defaults: HTTPS-only enforced, `WEBSITES_ENABLE_APP_SERVICE_STORAGE = false`, `always_on` enabled except on `F1`/`D1` SKUs.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group |
| `azure_region` | `string` | Azure region |
| `service_plan_name` | `string` | Name of the App Service Plan |
| `app_name` | `string` | Name of the App Service |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `os_type` | `string` | `"Linux"` | `Linux` or `Windows` |
| `runtime` | `string` | `"node"` | One of `node`, `dotnet`, `python`, `java`, `php` |
| `runtime_version` | `string` | `null` | Runtime version. If `null`, uses the per-runtime default (`node` 22-lts, `dotnet` 10.0, `python` 3.11, `java` 17, `php` 8.3) |
| `sku_name` | `string` | `"B1"` | App Service Plan SKU (e.g. `F1`, `B1`, `S1`, `P1v3`) |
| `app_settings` | `map(string)` | `{}` | Application settings (environment variables) |
| `key_vault_secret_refs` | `map(string)` | `{}` | App settings mapped to Key Vault Secret URIs; resolved at runtime via managed identity |
| `tags` | `map(string)` | `{}` | Resource tags |

---

## Outputs

| Name | Description |
|------|-------------|
| `app_service_id` | App Service resource ID |
| `app_service_name` | App Service name (consumed by EPIC deploy stage) |
| `default_hostname` | Default App Service hostname |
| `service_plan_id` | App Service Plan ID |
| `principal_id` | Managed identity principal ID |

---

## Usage in a Terraform project

In an application's `.infra/main.tf`:

```hcl
module "app_service" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"

  service_plan_name = "asp-my-app-dev"
  app_name          = "my-app-dev"

  runtime         = "php"
  runtime_version = "8.3"

  app_settings = {
    APP_ENV = "dev"
  }

  tags = {
    application = "my-app"
    environment = "dev"
  }
}
```

In `.infra/outputs.tf`, re-export the two values EPIC's deploy stage reads from `terraform-outputs`:

```hcl
output "app_service_name" {
  value = module.app_service.app_service_name
}

output "resource_group_name" {
  value = "rg-my-app-dev"
}

output "app_url" {
  value = "https://${module.app_service.default_hostname}"
}
```

`app_url` is optional but lets the IntegrationTest stage resolve `BASE_URL` automatically when `integrationTestTool` is set in `.pipeline/epic.json`.

---

## Usage from another module

```hcl
module "app_service" {
  source = "../epic-pipeline-module-azure-app-service"

  resource_group_name = azurerm_resource_group.this.name
  azure_region        = azurerm_resource_group.this.location

  service_plan_name = local.service_plan_name
  app_name          = local.app_name

  os_type = "Windows"
  runtime = "dotnet"

  key_vault_secret_refs = {
    DATABASE_URL = module.key_vault.secret_uris["database-url"]
  }

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

- Python and PHP application stacks are Linux-only in Azure App Service. Setting `os_type = "Windows"` with `runtime = "python"` or `"php"` will provision the plan and app, but the runtime stack will not be applied on Windows.
- Windows .NET versions are passed to `azurerm_windows_web_app` with the `v` prefix internally; pass plain values (e.g. `"10.0"`) via `runtime_version`.
- Networking, monitoring, and deployment slots are out of scope — compose them as separate resources or modules.
