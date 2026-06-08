# EPIC Azure Key Vault Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-key-vault
**Module Type:** Tier 0 -- Secrets Management Primitive
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **standard Azure Key Vault Terraform module** used by PG&E's
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This is the **Azure equivalent of aws-secretmanager** -- the canonical EPIC secrets management primitive for Azure workloads.

The module delivers a **secure, policy-aligned Key Vault** with:

- RBAC authorization by default (no legacy access policies)
- Purge protection enabled
- Soft delete with configurable retention
- TLS-enforced access
- Optional network ACLs
- Optional initial secret provisioning

---

## Design Principles

- RBAC-first (Azure RBAC instead of vault access policies)
- Secure by default (purge protection, soft delete)
- No secrets in Terraform state (use `sensitive = true` on inputs)
- Network isolation ready (optional ACLs)
- Compatible with EPIC auto-wiring and App Service Key Vault references
- Clean separation between vault creation and secret consumption

---

## What This Module Is (and Is Not)

### This module IS
- A standard Azure Key Vault implementation
- A shared secrets management primitive for all Azure workloads
- A Tier 0 EPIC building block
- Safe for direct consumption by application teams

### This module is NOT
- A certificate management module
- A key management / HSM module
- A deployment or CI/CD module
- A place to embed org- or app-specific policy logic

---

## Resources Created

- azurerm_key_vault
- azurerm_key_vault_secret (one per entry in `secrets` map)

No networking, logging, or monitoring resources are created directly.

---

## Security Defaults

The following controls are enforced automatically:

- Azure RBAC authorization (no legacy access policies)
- Purge protection enabled
- Soft delete with 90-day retention
- TLS-only access

### App Service Integration

This module outputs **versionless secret URIs** suitable for App Service Key Vault references:

```text
@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/my-secret)
```

Pass the `secret_uris` output directly to the App Service module's `key_vault_secret_refs` input.

---

## Inputs

### Required Inputs

| Name | Description |
|------|-------------|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| key_vault_name | Key Vault name (3-24 chars, alphanumeric and hyphens) |
| tags | Resource tags |

---

### Vault Configuration

| Name | Description | Default |
|------|-------------|---------|
| sku_name | Key Vault SKU (standard or premium) | standard |
| soft_delete_retention_days | Soft delete retention (7-90 days) | 90 |
| purge_protection_enabled | Prevent permanent deletion during retention | true |
| enable_rbac_authorization | Use Azure RBAC instead of access policies | true |
| enabled_for_deployment | Allow VMs to retrieve certificates | false |
| enabled_for_disk_encryption | Allow Azure Disk Encryption access | false |
| enabled_for_template_deployment | Allow ARM template access | false |

---

### Network Configuration

| Name | Description | Default |
|------|-------------|---------|
| network_acls | Network ACL rules (default_action, bypass, ip_rules, virtual_network_subnet_ids) | null |

---

### Secrets

| Name | Description | Default |
|------|-------------|---------|
| secrets | Map of secret name to secret value (sensitive) | {} |

---

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | Key Vault resource ID |
| key_vault_name | Key Vault name |
| key_vault_uri | Key Vault URI |
| secret_uris | Map of secret name to versionless URI (for App Service Key Vault references) |

---

## Example Usage — Key Vault + App Service Integration

```hcl
module "key_vault" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-key-vault.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  key_vault_name = "kv-example-dev"

  secrets = {
    "ConnectionStrings--DefaultConnection" = var.db_connection_string
    "GitHub--Token"                        = var.github_token
  }

  tags = {
    owner       = "team-x"
    environment = "dev"
  }
}

module "api_app" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service-linux.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  service_plan_name = "asp-example-dev"
  app_name          = "example-api-dev"

  runtime        = "dotnet"
  dotnet_version = "10.0"

  key_vault_secret_refs = module.key_vault.secret_uris

  tags = {
    owner       = "team-x"
    environment = "dev"
  }
}
```

---

## Example Usage — Network-Restricted Vault

```hcl
module "key_vault" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-key-vault.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  key_vault_name = "kv-example-prod"
  sku_name       = "premium"

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [module.network.subnet_id]
  }

  tags = {
    owner       = "team-x"
    environment = "prod"
  }
}
```

---

## EPIC Usage (resources.yml)

```yaml
parameters:
  tenant_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  azure_region: "westus"
  environment: "dev"

modules:
  - name: key_vault
    path: epic-pipeline-module-azure-key-vault
    variables:
      key_vault_name: "kv-example-dev"

      tags: module.tags.tags
```

---

## Terraform Compatibility

- Terraform >= 1.5
- AzureRM Provider >= 3.100

---

## Why This Module Exists

This module exists to:

- Standardize Azure Key Vault deployments
- Remove copy-paste secrets infrastructure
- Enforce consistent security defaults (RBAC, purge protection)
- Enable seamless integration with App Service Key Vault references
- Serve as the canonical EPIC secrets management primitive for Azure

It is **infrastructure**, not deployment logic.

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:

- Certificate management (import, rotation, issuance)
- HSM-backed keys
- Private endpoint connectivity
- Diagnostic logging to Log Analytics

Use or compose a **higher-level EPIC module** that builds on this foundation.

This module should remain **clean, minimal, and secrets-focused**.
