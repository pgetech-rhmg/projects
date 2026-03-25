# EPIC Azure PostgreSQL Flexible Server Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-postgresql
**Module Type:** Tier 1 -- Database Infrastructure Module
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **standard Azure PostgreSQL Flexible Server Terraform module** used by PG&E's
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module delivers a **secure, policy-aligned PostgreSQL Flexible Server** suitable for:

- Application databases (relational workloads)
- Backend data stores for APIs and services
- Development, staging, and production environments

The module is intentionally **opinionated where it matters** (security, authentication, structure) and **flexible where it must be** (SKU, storage, networking, databases).

It serves as the **canonical EPIC PostgreSQL primitive** -- the Azure equivalent of Aurora PostgreSQL on AWS.

---

## Design Principles

This module follows strict enterprise standards:

- Flexible Server only (Single Server is deprecated)
- Secure by default (SSL enforced, password authentication required)
- Password auto-generation when not explicitly provided
- No secrets stored in Terraform state unless unavoidable
- Explicit configuration via inputs
- Compatible with EPIC auto-wiring and orchestration

---

## Resources Created

This module creates the following Azure resources:

- azurerm_postgresql_flexible_server
- azurerm_postgresql_flexible_server_database (one per entry in `databases`)
- azurerm_postgresql_flexible_server_firewall_rule (one per entry in `firewall_rules`)
- random_password (when `admin_password` is null)

No networking, logging, or monitoring resources are created directly.

---

## Security Defaults

The following controls are enforced automatically:

- Password authentication enabled via `authentication` block
- SSL enforced by Azure Flexible Server defaults
- Admin password auto-generated (24 characters, special characters) when not provided
- No public firewall rules unless explicitly configured
- VNet integration supported via `delegated_subnet_id`

---

## Inputs

### Required Inputs

| Name | Description |
|----|----|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| server_name | PostgreSQL Flexible Server name |
| tags | Resource tags |

---

### Server Configuration

| Name | Description | Default |
|----|----|----|
| postgresql_version | PostgreSQL major version (13, 14, 15, 16) | 16 |
| sku_name | Flexible Server SKU | B_Standard_B1ms |
| storage_mb | Storage in MB | 32768 |
| storage_tier | Storage performance tier | P4 |
| zone | Availability zone | null |

---

### Backup Configuration

| Name | Description | Default |
|----|----|----|
| backup_retention_days | Backup retention in days (7-35) | 7 |
| geo_redundant_backup_enabled | Enable geo-redundant backups | false |

---

### Authentication

| Name | Description | Default |
|----|----|----|
| admin_username | Administrator login name | epicadmin |
| admin_password | Administrator password (auto-generated if null) | null |

---

### Database Configuration

| Name | Description | Default |
|----|----|----|
| databases | List of databases to create (name, charset, collation) | [] |
| firewall_rules | List of firewall rules (name, start_ip, end_ip) | [] |

---

### Networking

| Name | Description | Default |
|----|----|----|
| delegated_subnet_id | Subnet for private network access | null |
| private_dns_zone_id | Private DNS zone for FQDN resolution | null |

---

## Outputs

| Name | Description |
|----|----|
| server_id | PostgreSQL Flexible Server resource ID |
| server_name | PostgreSQL Flexible Server name |
| server_fqdn | Fully qualified domain name |
| admin_username | Administrator login name |
| admin_password | Administrator password (sensitive) |
| database_names | List of created database names |

---

## Example Usage (Direct Terraform)

### Minimal (Public Access, Auto-Generated Password)

```hcl
module "postgres" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-postgresql.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  server_name = "psql-example-dev"

  databases = [
    { name = "appdb" }
  ]

  firewall_rules = [
    { name = "allow-azure", start_ip = "0.0.0.0", end_ip = "0.0.0.0" }
  ]

  tags = {
    owner = "team-x"
  }
}
```

---

### Production (VNet Integration, Custom Password)

```hcl
module "postgres" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-postgresql.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  server_name        = "psql-example-prod"
  postgresql_version = "16"
  sku_name           = "GP_Standard_D2s_v3"
  storage_mb         = 65536
  storage_tier       = "P6"

  backup_retention_days        = 35
  geo_redundant_backup_enabled = true
  zone                         = "1"

  admin_password = var.db_admin_password

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  databases = [
    { name = "appdb" },
    { name = "analyticsdb", charset = "UTF8", collation = "en_US.utf8" }
  ]

  tags = {
    owner       = "team-y"
    environment = "prod"
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
  - name: postgres
    path: epic-pipeline-module-azure-postgresql
    variables:
      server_name: "psql-example-dev"
      sku_name: GP_Standard_D2s_v3
      databases:
        - name: appdb
      tags: module.tags.tags
```

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "postgres" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-postgresql.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region
  server_name         = var.server_name
}
```

Additional concerns (monitoring, networking, access) should be layered **outside** this module.

---

## Naming Conventions

This module does not enforce naming directly.

Typical EPIC naming patterns resolve to:

```text
psql-<app>-<environment>
```

Example:

```text
psql-example-prod
```

Final naming decisions are owned by the EPIC pipeline or consuming module.

---

## Terraform Compatibility

- Terraform >= 1.5
- AzureRM Provider >= 3.100

---

## Why This Module Exists

This module exists to:

- Standardize Azure PostgreSQL Flexible Server deployments
- Remove copy-paste infrastructure definitions
- Enforce consistent security defaults
- Enable flexible database provisioning without duplication
- Serve as the canonical EPIC PostgreSQL primitive

It is **infrastructure**, not deployment logic.

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:

- Read replicas
- High availability with zone-redundant failover
- Connection pooling (PgBouncer)
- Advanced networking (private endpoints)
- Monitoring and diagnostics

Use or compose a **higher-level EPIC module** that builds on this foundation.

This module should remain **clean, minimal, and database-focused**.
