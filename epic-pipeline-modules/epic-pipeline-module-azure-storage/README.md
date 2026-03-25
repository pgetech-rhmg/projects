# EPIC Azure Storage Module (Tier 0)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-storage
**Module Type:** Tier 0 -- Foundational Storage Primitive
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **standard Azure Storage Account Terraform module** used by PG&E's
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This is the **Azure equivalent of the aws-s3 module** -- a foundational, secure-by-default storage primitive for blob, container, and general-purpose storage workloads.

The module is intentionally **secure where it matters** (HTTPS only, TLS 1.2, no public blob access, soft delete) and **flexible where it must be** (replication, containers, network rules).

It serves as the **canonical EPIC Azure Storage primitive** upon which higher-level, purpose-specific modules may be built.

---

## Design Principles

This module follows strict enterprise standards:

- Secure by default (HTTPS only, TLS 1.2 minimum, no public blob access)
- Soft delete enabled for blobs and containers
- Policy-agnostic -- no org-specific policy logic embedded
- Explicit configuration via inputs
- Compatible with EPIC auto-wiring and orchestration

---

## What This Module Is (and Is Not)

### This module IS
- A standard Azure Storage Account implementation
- A shared storage primitive for blob and general-purpose workloads
- A Tier 0 EPIC building block
- Safe for direct consumption by application teams

### This module is NOT
- A CDN or static website hosting module
- A Data Lake Storage module (though StorageV2 supports HNS separately)
- A deployment or CI/CD module
- A place to embed org- or app-specific policy logic

---

## Resources Created

This module creates the following Azure resources:

- azurerm_storage_account
- azurerm_storage_container (zero or more, based on `containers` input)

No networking, logging, or monitoring resources are created directly.

---

## Security Defaults

The following controls are enforced by default:

- HTTPS-only traffic
- TLS 1.2 minimum
- No public blob access
- Blob soft delete (7 days)
- Container soft delete (7 days)

---

## Inputs

### Required Inputs

| Name | Description |
|------|-------------|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| storage_account_name | Storage account name (3-24 chars, lowercase alphanumeric only) |
| tags | Resource tags |

---

### Storage Account Configuration

| Name | Description | Default |
|------|-------------|---------|
| account_tier | Standard or Premium | Standard |
| account_replication_type | LRS, GRS, RAGRS, or ZRS | LRS |
| account_kind | StorageV2, BlobStorage, or BlockBlobStorage | StorageV2 |
| min_tls_version | Minimum TLS version | TLS1_2 |
| allow_blob_public_access | Allow public access to blobs | false |
| enable_https_traffic_only | Require HTTPS traffic only | true |

---

### Data Protection

| Name | Description | Default |
|------|-------------|---------|
| enable_versioning | Enable blob versioning | false |
| enable_blob_soft_delete | Enable blob soft delete | true |
| blob_soft_delete_days | Soft-deleted blob retention days | 7 |
| enable_container_soft_delete | Enable container soft delete | true |
| container_soft_delete_days | Soft-deleted container retention days | 7 |

---

### Containers

| Name | Description | Default |
|------|-------------|---------|
| containers | List of containers to create (name + access_type) | [] |

---

### Network Rules

| Name | Description | Default |
|------|-------------|---------|
| network_rules | Network rules (default_action, ip_rules, virtual_network_subnet_ids) | null |

---

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | Storage account resource ID |
| storage_account_name | Storage account name |
| primary_blob_endpoint | Primary blob service endpoint |
| primary_access_key | Primary access key (sensitive) |
| primary_connection_string | Primary connection string (sensitive) |

---

## Example Usage (Direct Terraform)

### Basic Storage Account

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name  = "rg-example-dev"
  azure_region         = "westus"
  storage_account_name = "pgeexampledev"

  tags = {
    owner = "team-x"
  }
}
```

---

### With Containers and Network Rules

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name  = "rg-example-prod"
  azure_region         = "westus"
  storage_account_name = "pgeexampleprod"

  account_replication_type = "GRS"
  enable_versioning        = true

  containers = [
    { name = "data",    access_type = "private" },
    { name = "backups", access_type = "private" },
  ]

  network_rules = {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = []
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
  - name: storage
    path: epic-pipeline-module-azure-storage
    variables:
      storage_account_name: "pgeexampledev"
      account_replication_type: GRS

      tags: module.tags.tags
```

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "storage" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-storage.git"

  tenant_id            = var.tenant_id
  subscription_id      = var.subscription_id
  resource_group_name  = var.resource_group_name
  azure_region         = var.azure_region
  storage_account_name = var.storage_account_name
}
```

Additional concerns (monitoring, networking, lifecycle policies) should be layered **outside** this module.

---

## Naming Conventions

This module does not enforce naming directly.

Storage account names must be globally unique, 3-24 characters, lowercase alphanumeric only.

Typical EPIC naming patterns resolve to:

```text
pge<app><environment>
```

Example:

```text
pgeexampleprod
```

Final naming decisions are owned by the EPIC pipeline or consuming module.

---

## Terraform Compatibility

- Terraform >= 1.5
- AzureRM Provider >= 3.100

---

## Why This Module Exists

This module exists to:

- Standardize Azure Storage Account deployments
- Remove copy-paste infrastructure definitions
- Enforce consistent security defaults (HTTPS, TLS, no public access, soft delete)
- Enable flexible storage configurations without duplication
- Serve as the canonical EPIC Azure Storage primitive

It is **infrastructure**, not deployment logic.

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:

- Static website hosting
- Azure Data Lake Storage (HNS)
- Lifecycle management policies
- Private endpoints
- Diagnostics and logging

Use or compose a **higher-level EPIC module** that builds on this foundation.

This module should remain **clean, minimal, and policy-agnostic**.
