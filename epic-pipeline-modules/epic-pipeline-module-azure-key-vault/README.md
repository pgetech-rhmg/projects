# EPIC Azure Key Vault Module

## Overview

Provisions an Azure Key Vault for secrets, keys, and certificates used by EPIC-managed Azure workloads. The vault defaults to RBAC authorization, soft-delete with purge protection, and supports optional network ACLs and bulk creation of initial secrets (suitable for App Service Key Vault references).

This module is consumed from an application's `.infra/` directory, which is provisioned by the EPIC pipeline when an app's `.pipeline/epic.json` declares Azure as the cloud target.

## Resources

- `azurerm_key_vault.this` — the Key Vault
- `azurerm_key_vault_secret.this` — one secret per entry in `var.secrets` (created via `for_each`)
- `azurerm_client_config.current` (data) — resolves the current tenant ID

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group |
| `azure_region` | `string` | Azure region |
| `key_vault_name` | `string` | Name of the Key Vault — must be 3-24 chars, alphanumeric and hyphens |
| `tags` | `map(string)` | Resource tags |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sku_name` | `string` | `"standard"` | Key Vault SKU (`standard` or `premium`) |
| `soft_delete_retention_days` | `number` | `90` | Days to retain soft-deleted vaults and secrets (7-90) |
| `purge_protection_enabled` | `bool` | `true` | Prevent permanent deletion during the retention period |
| `enable_rbac_authorization` | `bool` | `true` | Use Azure RBAC instead of vault access policies |
| `enabled_for_deployment` | `bool` | `false` | Allow Azure VMs to retrieve certificates stored as secrets |
| `enabled_for_disk_encryption` | `bool` | `false` | Allow Azure Disk Encryption to retrieve secrets and unwrap keys |
| `enabled_for_template_deployment` | `bool` | `false` | Allow Azure Resource Manager to retrieve secrets |
| `network_acls` | `object({ default_action, bypass, ip_rules, virtual_network_subnet_ids })` | `null` | Network ACL rules for the Key Vault |
| `secrets` | `map(string)` | `{}` | Initial secrets to create — map of secret name to secret value |

## Outputs

| Name | Description |
|------|-------------|
| `key_vault_id` | ID of the Key Vault |
| `key_vault_name` | Name of the Key Vault |
| `key_vault_uri` | URI of the Key Vault |
| `secret_uris` | Map of secret name to versionless URI (for App Service Key Vault references) |

## Usage in a Terraform project

Typical usage from an application's `.infra/main.tf`:

```hcl
module "key_vault" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-key-vault.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  key_vault_name      = "kv-my-app-dev"

  tags = {
    Environment = "dev"
    Application = "my-app"
  }

  secrets = {
    "DB-PASSWORD" = var.db_password
    "API-KEY"     = var.api_key
  }
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}
```

A locked-down vault with network ACLs and the premium SKU:

```hcl
module "key_vault" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-key-vault.git?ref=main"

  resource_group_name = "rg-my-app-prod"
  azure_region        = "westus2"
  key_vault_name      = "kv-my-app-prod"
  sku_name            = "premium"

  tags = {
    Environment = "prod"
    Application = "my-app"
  }

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }
}
```

## Usage from another module

Compose the Key Vault alongside other EPIC modules — for example, wiring secret URIs into an App Service:

```hcl
module "key_vault" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-key-vault.git?ref=main"

  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region
  key_vault_name      = "kv-${var.app_name}-${var.environment}"
  tags                = var.tags

  secrets = {
    "DB-CONNECTION" = var.db_connection_string
  }
}

module "app_service" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git?ref=main"

  # ...

  app_settings = {
    "DB_CONNECTION" = "@Microsoft.KeyVault(SecretUri=${module.key_vault.secret_uris["DB-CONNECTION"]})"
  }
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 3.100` |

## Notes

- `enable_rbac_authorization` defaults to `true`. If you opt out, you are responsible for declaring `azurerm_key_vault_access_policy` resources outside this module.
- `purge_protection_enabled` defaults to `true` and cannot be reversed once enabled on the underlying vault — plan accordingly for non-production environments where you may want to recreate vaults.
- Secrets passed via `var.secrets` are stored in Terraform state. Source them from variables marked `sensitive = true` and avoid committing values to `terraform.auto.tfvars`.
- App Service Key Vault references should use the `versionless_id` returned in `secret_uris` so rotated secret versions are picked up automatically.
- The vault's `tenant_id` is resolved from the active Azure provider via `azurerm_client_config` — there is no `tenant_id` input on this module.
