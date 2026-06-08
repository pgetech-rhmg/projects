# EPIC Azure Function Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-function
**Module Type:** Tier 1 - Serverless Compute Infrastructure Module
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **standard Azure Function App Terraform module** used by PG&E's
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module delivers a **secure, policy-aligned, runtime-flexible Linux Function App** suitable for:

- Event-driven serverless workloads
- Lightweight API backends
- Scheduled jobs and background processing

Consumption plan (Y1 SKU) by default. HTTPS enforced. System-assigned managed identity enabled.

The module is intentionally **opinionated where it matters** (security, identity, structure) and **flexible where it must be** (runtime, SKU, app settings, Key Vault integration).

---

## Design Principles

This module follows strict enterprise standards:

- Linux-only (explicit and intentional)
- Consumption plan by default (Y1 SKU)
- Secure by default (HTTPS-only)
- Identity-first (managed identity enabled)
- Runtime-flexible (Node.js, .NET, Python)
- No secrets in Terraform state
- Explicit configuration via inputs
- Compatible with EPIC auto-wiring and orchestration

---

## What This Module Is (and Is Not)

### This module IS
- A standard Linux Azure Function App implementation
- A serverless compute primitive for event-driven workloads
- A Tier 1 EPIC building block
- Safe for direct consumption by application teams

### This module is NOT
- A Windows Function App module
- A container-based hosting solution
- A deployment or CI/CD module
- A storage account provisioner (depends on separate azure-storage module)

---

## Resources Created

This module creates the following Azure resources:

- azurerm_service_plan (Consumption by default)
- azurerm_linux_function_app
- System-assigned managed identity

No storage accounts, networking, logging, or monitoring resources are created directly.

**Storage dependency:** This module requires an existing storage account. Use the `epic-pipeline-module-azure-storage` module to provision one.

---

## Security Defaults

The following controls are enforced automatically:

- HTTPS-only traffic
- Linux App Service Plan
- System-assigned managed identity
- No secrets stored in Terraform state

### Key Vault Integration

This module supports **native Function App Key Vault references** using:

```text
@Microsoft.KeyVault(SecretUri=...)
```

- Secrets are resolved at runtime
- No Key Vault SDK or application code changes required
- Access is controlled via managed identity + RBAC or access policies

**Important:**
This module does **not** grant Key Vault access automatically.
Access must be granted explicitly by the caller.

---

## Inputs

### Required Inputs

| Name | Description |
|------|-------------|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| function_app_name | Function App name |
| storage_account_name | Storage account for Function App state |
| storage_account_access_key | Storage account access key (sensitive) |
| tags | Resource tags |

---

### Runtime Configuration

| Name | Description | Default |
|------|-------------|---------|
| runtime | Application runtime (node, dotnet, or python) | node |
| runtime_version | Runtime-specific version. If null, uses defaults | null |

Default runtime versions when `runtime_version` is null:

| Runtime | Default Version |
|---------|----------------|
| node | 20 |
| dotnet | 10.0 |
| python | 3.11 |

---

### Application Configuration

| Name | Description | Default |
|------|-------------|---------|
| app_settings | Arbitrary application settings | {} |
| key_vault_secret_refs | App settings mapped to Key Vault Secret URIs | {} |
| https_only | Enforce HTTPS-only traffic | true |
| functions_extension_version | Azure Functions runtime version | ~4 |

---

### Service Plan Configuration

| Name | Description | Default |
|------|-------------|---------|
| service_plan_name | App Service Plan name. If null, auto-generates from function app name. | null |
| sku_name | App Service Plan SKU | Y1 |

SKU options:
- **Y1** - Consumption (serverless, pay-per-execution)
- **EP1/EP2/EP3** - Elastic Premium (VNet, always-ready instances)
- **B1/S1** - Dedicated (App Service Plan)

---

## Outputs

| Name | Description |
|------|-------------|
| function_app_id | Function App resource ID |
| function_app_name | Function App name |
| default_hostname | Default Function App hostname |
| service_plan_id | App Service Plan ID |
| principal_id | Managed identity principal ID |

---

## Example Usage (Direct Terraform)

### Consumption Plan + Node.js

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git"

  tenant_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  storage_account_name = "stexamplefuncdev"

  tags = {
    owner = "team-x"
  }
}

module "function_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-function.git"

  tenant_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  function_app_name          = "func-example-dev"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.primary_access_key

  runtime = "node"

  app_settings = {
    app_environment = "dev"
  }

  tags = {
    owner = "team-x"
  }
}
```

---

### .NET Isolated + Premium Plan

```hcl
module "function_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-function.git"

  tenant_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  function_app_name          = "func-example-api-prod"
  storage_account_name       = "stexamplefuncprod"
  storage_account_access_key = var.storage_access_key

  runtime         = "dotnet"
  runtime_version = "10.0"
  sku_name        = "EP1"

  app_settings = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }

  key_vault_secret_refs = {
    DatabaseConnection = "https://kv-example.vault.azure.net/secrets/db-connection"
  }

  tags = {
    owner = "team-y"
  }
}
```

---

### Python Function

```hcl
module "function_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-function.git"

  tenant_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  function_app_name          = "func-etl-processor-dev"
  storage_account_name       = "stetlprocessordev"
  storage_account_access_key = var.storage_access_key

  runtime = "python"

  tags = {
    owner = "team-data"
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
  - name: storage
    path: epic-pipeline-module-azure-storage
    variables:
      storage_account_name: "stexamplefuncdev"
      tags: module.tags.tags

  - name: function_app
    path: epic-pipeline-module-azure-function
    variables:
      function_app_name: "func-example-dev"
      storage_account_name: module.storage.storage_account_name
      storage_account_access_key: module.storage.primary_access_key
      runtime: node
      tags: module.tags.tags
```

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "function_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-function.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region

  function_app_name          = var.function_app_name
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  runtime         = var.runtime
  runtime_version = var.runtime_version
}
```

Additional concerns (monitoring, networking, access) should be layered **outside** this module.

---

## Terraform Compatibility

- Terraform >= 1.5
- AzureRM Provider >= 3.100

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.
