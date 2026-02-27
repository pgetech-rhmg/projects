# EPIC Azure App Service (Linux) Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps  
**Module Name:** epic-pipeline-module-azure-app-service-linux  
**Module Type:** Tier 1 – Application Hosting Infrastructure Module  
**Last Updated:** 2026-01-27

---

## Overview

This repository provides the **standard Azure App Service (Linux) Terraform module** used by PG&E’s  
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module delivers a **secure, policy-aligned, runtime-agnostic Linux App Service** suitable for hosting:

- Node.js user interfaces  
- .NET APIs  
- Other supported Linux App Service runtimes  

The module is intentionally **opinionated where it matters** (security, identity, structure) and **flexible where it must be** (runtime, app settings, Key Vault integration).

It serves as the **canonical EPIC App Service primitive** upon which higher-level, purpose-specific modules (UX, API, backend services) may be built.

---

## Design Principles

This module follows strict enterprise standards:

- Linux-only (explicit and intentional)  
- Secure by default  
- Identity-first (managed identity enabled)  
- Runtime-agnostic (Node.js, .NET)  
- No secrets in Terraform state  
- Explicit configuration via inputs  
- Compatible with EPIC auto-wiring and orchestration  

This ensures:

- Predictable runtime behavior  
- Consistent security posture  
- Clear separation of infrastructure and application concerns  
- Safe reuse across multiple application types  

---

## What This Module Is (and Is Not)

### ✅ This module IS
- A standard Linux Azure App Service implementation  
- A shared hosting primitive for UI and API workloads  
- A Tier 1 EPIC building block  
- Safe for direct consumption by application teams  

### ❌ This module is NOT
- A Windows App Service module  
- A container-based hosting solution  
- A deployment or CI/CD module  
- A place to embed org- or app-specific policy logic  

---

## Resources Created

This module creates the following Azure resources:

- azurerm_service_plan  
- azurerm_linux_web_app  
- System-assigned managed identity  

No networking, logging, or monitoring resources are created directly.

---

## Security Defaults

The following controls are enforced automatically:

- HTTPS-only traffic  
- Linux App Service Plan  
- System-assigned managed identity  
- No local file system persistence  
- No secrets stored in Terraform state  

### Key Vault Integration

This module supports **native App Service Key Vault references** using:

```text
@Microsoft.KeyVault(SecretUri=...)
```

- Secrets are resolved at runtime  
- No Key Vault SDK or application code changes required  
- Access is controlled via managed identity + RBAC or access policies  

⚠️ **Important:**  
This module does **not** grant Key Vault access automatically.  
Access must be granted explicitly by the caller.

---

## Inputs

### Required Inputs

| Name | Description |
|----|----|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| service_plan_name | App Service Plan name |
| app_name | App Service name |
| tags | Resource tags |

---

### Runtime Configuration

| Name | Description | Default |
|----|----|----|
| runtime | Application runtime (node or dotnet) | node |
| node_version | Node.js version (when runtime = node) | 22-lts |
| dotnet_version | .NET version (when runtime = dotnet) | 10.0 |

---

### Application Configuration

| Name | Description | Default |
|----|----|----|
| app_settings | Arbitrary application settings | {} |
| key_vault_secret_refs | App settings mapped to Key Vault Secret URIs | {} |

Examples of valid app settings include:

- ASPNETCORE_ENVIRONMENT  
- app_environment  
- FEATURE_FLAG_X  

---

### Service Plan Configuration

| Name | Description | Default |
|----|----|----|
| sku_name | App Service Plan SKU | B1 |

---

## Outputs

| Name | Description |
|----|----|
| app_service_id | App Service resource ID |
| app_service_name | App Service name |
| default_hostname | Default App Service hostname |
| service_plan_id | App Service Plan ID |
| principal_id | Managed identity principal ID |

---

## Example Usage (Direct Terraform)

> For application teams or EPIC module authors

### Node.js UX

```hcl
module "ux_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service-linux.git"

  tenant_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  service_plan_name = "asp-example-dev"
  app_name          = "example-ux-dev"

  runtime      = "node"
  node_version = "22-lts"

  app_settings = {
    app_environment = "dev"
  }

  tags = {
    owner = "team-x"
  }
}
```

---

### .NET API

```hcl
module "api_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service-linux.git"

  tenant_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  service_plan_name = "asp-example-prod"
  app_name          = "example-api-prod"

  runtime        = "dotnet"
  dotnet_version = "10.0"

  app_settings = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }

  tags = {
    owner = "team-y"
  }
}
```

---

## EPIC Usage (resources.yml)

This module is intended for **direct use within EPIC**.

```yaml
parameters:
  tenant_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  azure_region: "westus"
  environment: "dev"

modules:
  - name: app_service
    path: epic-pipeline-module-azure-app-service-linux
    variables:
      service_plan_name: "asp-example-prod"
      app_name: "example-api-prod"
      runtime: dotnet
      sku_name: S1

      tags: module.tags.tags
```

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "app_service" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service-linux.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region
  service_plan_name   = var.service_plan_name
  app_name            = var.app_name
  runtime             = var.runtime
}
```

Additional concerns (monitoring, networking, access) should be layered **outside** this module.

---

## Naming Conventions

This module does not enforce naming directly.

Typical EPIC naming patterns resolve to:

```text
<prefix>-<app>-<environment>-<role>
```

Example:

```text
pge-example-prod-api
```

Final naming decisions are owned by the EPIC pipeline or consuming module.

---

## Terraform Compatibility

- Terraform >= 1.5  
- AzureRM Provider >= 3.100  

---

## Why This Module Exists

This module exists to:

- Standardize Azure App Service deployments  
- Remove copy-paste infrastructure definitions  
- Enforce consistent security defaults  
- Enable runtime flexibility without duplication  
- Serve as the canonical EPIC App Service primitive  

It is **infrastructure**, not deployment logic.

---

## Ownership

Maintained by:  
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:

- Windows App Services  
- Containers or Azure Container Apps  
- Deployment slots  
- VNet integration  
- App Insights and diagnostics  

👉 Use or compose a **higher-level EPIC module** that builds on this foundation.

This module should remain **clean, minimal, and runtime-agnostic**.
