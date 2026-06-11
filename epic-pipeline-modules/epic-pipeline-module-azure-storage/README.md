# EPIC Azure Storage Module

## Overview

`epic-pipeline-module-azure-storage` provisions an Azure Storage Account and (optionally) its blob containers as a reusable building block for EPIC-managed Azure infrastructure.

It is intended to be consumed from an application's `.infra/` Terraform directory or composed into a higher-level EPIC module. The module is secure by default (TLS 1.2 minimum, no public blob access, blob and container soft delete enabled) and exposes the levers application teams typically need (replication, kind, containers, network rules) without embedding org-specific policy.

---

## Resources Created

- `azurerm_storage_account`
- `azurerm_storage_container` (zero or more, driven by the `containers` input)

No networking, diagnostic, or monitoring resources are created.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group the storage account is created in. |
| `azure_region` | `string` | Azure region for the storage account. |
| `storage_account_name` | `string` | Storage account name. Must be 3-24 chars, lowercase alphanumeric only, and globally unique. |
| `tags` | `map(string)` | Resource tags applied to the storage account. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `account_tier` | `string` | `Standard` | Storage account performance level. One of `Standard`, `Premium`. |
| `account_replication_type` | `string` | `LRS` | Replication strategy. One of `LRS`, `GRS`, `RAGRS`, `ZRS`. |
| `account_kind` | `string` | `StorageV2` | Storage account kind. One of `StorageV2`, `BlobStorage`, `BlockBlobStorage`. |
| `min_tls_version` | `string` | `TLS1_2` | Minimum TLS version accepted by the storage account. |
| `allow_blob_public_access` | `bool` | `false` | Whether nested blobs may be publicly accessible. |
| `enable_versioning` | `bool` | `false` | Enable blob versioning. |
| `enable_blob_soft_delete` | `bool` | `true` | Enable soft delete for blobs. |
| `blob_soft_delete_days` | `number` | `7` | Retention in days for soft-deleted blobs. |
| `enable_container_soft_delete` | `bool` | `true` | Enable soft delete for containers. |
| `container_soft_delete_days` | `number` | `7` | Retention in days for soft-deleted containers. |
| `containers` | `list(object({ name = string, access_type = string }))` | `[]` | Containers to create. `access_type` should be `"private"` for EPIC workloads. |
| `network_rules` | `object({ default_action = string, ip_rules = list(string), virtual_network_subnet_ids = list(string) })` | `null` | Network ACLs. When `null`, no network rules are configured. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `storage_account_id` | No | Resource ID of the storage account. |
| `storage_account_name` | No | Name of the storage account. |
| `primary_blob_endpoint` | No | Primary blob service endpoint URL. |
| `primary_access_key` | Yes | Primary access key for the storage account. |
| `primary_connection_string` | Yes | Primary connection string for the storage account. |

---

## Usage in a Terraform Project

Reference the module from an application's `.infra/main.tf` as a pinned Git source:

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git?ref=main"

  resource_group_name  = "rg-my-app-dev"
  azure_region         = "westus2"
  storage_account_name = "pgemyappdev"

  containers = [
    { name = "data",    access_type = "private" },
    { name = "backups", access_type = "private" },
  ]

  tags = {
    app         = "my-app"
    environment = "dev"
  }
}
```

For production-leaning configurations:

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git?ref=main"

  resource_group_name  = "rg-my-app-prod"
  azure_region         = "westus2"
  storage_account_name = "pgemyappprod"

  account_replication_type = "GRS"
  enable_versioning        = true

  network_rules = {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = []
  }

  tags = {
    app         = "my-app"
    environment = "prod"
  }
}
```

This module is designed to be consumed by Azure-targeted EPIC applications — apps that declare `cloud.azureSubscriptionId` in `.pipeline/epic.json` and provision their resources from `.infra/` during the EPIC `DeployInfra` stage.

---

## Usage from Another Module

Higher-level modules can wrap this one to add concerns like diagnostics, lifecycle policies, or private endpoints:

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git?ref=main"

  resource_group_name  = var.resource_group_name
  azure_region         = var.azure_region
  storage_account_name = var.storage_account_name
  tags                 = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  name               = "diag-${module.storage.storage_account_name}"
  target_resource_id = module.storage.storage_account_id
  # ...
}
```

Compose additional resources outside this module — keep this one focused on the storage account itself.

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 3.100` |

---

## Notes

- Storage account names must be globally unique across Azure, 3-24 characters, lowercase alphanumeric only. The module does not generate or mutate the name — callers are responsible for resolving it.
- `primary_access_key` and `primary_connection_string` outputs are marked `sensitive`. Consumers must propagate the sensitive flag if re-exporting them.
- When `network_rules` is set with `default_action = "Deny"`, ensure the executing pipeline agent's egress IP or subnet is included in `ip_rules` / `virtual_network_subnet_ids`, or subsequent Terraform operations against the account may fail.
