# EPIC Azure App Service Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-app-service
**Module Type:** Tier 1 - Application Hosting Infrastructure Module
**Last Updated:** 2026-03-25

---

## Overview

This module delivers a **secure, policy-aligned, runtime-agnostic Azure App Service** suitable for hosting:

- Node.js user interfaces
- .NET APIs
- Python applications
- Java applications
- PHP applications

Supports both **Linux** and **Windows** App Service Plans via the `os_type` variable.

This module replaces `epic-pipeline-module-azure-app-service-linux` with a unified implementation.

---

## Design Principles

- **OS-flexible** — Linux (default) or Windows via a single variable
- **Runtime-agnostic** — node, dotnet, python, java, php with sensible version defaults
- **Secure by default** — HTTPS-only, managed identity, no local file persistence
- **SKU-aware** — automatically disables `always_on` for free/shared tiers (F1, D1)
- **Key Vault native** — secret references resolved at runtime, no secrets in state
- **Version defaults** — mirrors the `runtimeVersion` + `coalesce` pattern from EPIC-Pipeline

---

## Resources Created

- `azurerm_service_plan`
- `azurerm_linux_web_app` (when os_type = Linux)
- `azurerm_windows_web_app` (when os_type = Windows)
- System-assigned managed identity

---

## Security Defaults

- HTTPS-only traffic enforced
- System-assigned managed identity enabled
- No local file system persistence (`WEBSITES_ENABLE_APP_SERVICE_STORAGE = false`)
- `always_on` enabled (except F1/D1 SKUs)

---

## Runtime Version Defaults

If `runtime_version` is not specified, the module uses these defaults:

| Runtime | Default Version |
|---------|----------------|
| node    | 22-lts         |
| dotnet  | 10.0           |
| python  | 3.11           |
| java    | 17             |
| php     | 8.3            |

---

## Inputs

### Required

| Name | Description |
|------|-------------|
| `tenant_id` | Azure tenant ID |
| `subscription_id` | Azure subscription ID |
| `resource_group_name` | Target resource group |
| `azure_region` | Azure region |
| `service_plan_name` | App Service Plan name |
| `app_name` | App Service name |
| `tags` | Resource tags |

### Optional

| Name | Description | Default |
|------|-------------|---------|
| `os_type` | Linux or Windows | Linux |
| `runtime` | node, dotnet, python, java, php | node |
| `runtime_version` | Runtime-specific version (null = use default) | null |
| `sku_name` | App Service Plan SKU | B1 |
| `app_settings` | Application settings (env vars) | {} |
| `key_vault_secret_refs` | App settings mapped to Key Vault Secret URIs | {} |

---

## Outputs

| Name | Description |
|------|-------------|
| `app_service_id` | App Service resource ID |
| `app_service_name` | App Service name |
| `default_hostname` | Default App Service hostname |
| `service_plan_id` | App Service Plan ID |
| `principal_id` | Managed identity principal ID |

---

## Example Usage

### Linux Node.js UI

```hcl
module "ux" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  service_plan_name = "asp-example-dev"
  app_name          = "example-ux-dev"

  runtime         = "node"
  runtime_version = "20-lts"

  tags = module.tags.tags
}
```

### Windows .NET API

```hcl
module "api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  service_plan_name = "asp-example-prod"
  app_name          = "example-api-prod"

  os_type         = "Windows"
  runtime         = "dotnet"
  runtime_version = "10.0"

  app_settings = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }

  tags = module.tags.tags
}
```

### Linux Python App with Key Vault

```hcl
module "backend" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  service_plan_name = "asp-example-dev"
  app_name          = "example-backend-dev"

  runtime = "python"

  key_vault_secret_refs = {
    DATABASE_URL = module.key_vault.secret_uris["database-url"]
  }

  tags = module.tags.tags
}
```

---

## Notes

- **Python and PHP are Linux-only** in Azure App Service. Setting `os_type = "Windows"` with `runtime = "python"` will deploy but the runtime won't be available.
- **Windows .NET** versions use the `v` prefix format internally (e.g., `v10.0`). The module handles this automatically.
- This module does not create networking, monitoring, or deployment slot resources. Compose higher-level modules for those concerns.

---

## Ownership

Maintained by: **PG&E Enterprise Cloud & DevSecOps**
Part of the **EPIC** ecosystem.
