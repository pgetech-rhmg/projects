# EPIC Azure SQL Database Module (Tier 1)

**Team:** PG&E Enterprise Cloud & DevSecOps
**Module Name:** epic-pipeline-module-azure-sql
**Module Type:** Tier 1 -- Database Infrastructure Module
**Last Updated:** 2026-03-25

---

## Overview

This repository provides the **standard Azure SQL Database Terraform module** used by PG&E's
**EPIC (Enterprise Pipeline for Infrastructure & Cloud)** platform.

This module delivers a **secure, policy-aligned Azure SQL Server and database** suitable for teams that prefer SQL Server over PostgreSQL.

The module is intentionally **opinionated where it matters** (security, TLS, public access) and **flexible where it must be** (databases, SKUs, firewall rules, Azure AD authentication).

---

## Design Principles

This module follows strict enterprise standards:

- Secure by default (TLS 1.2, public access disabled)
- Password auto-generation when not provided
- Azure AD authentication support
- Multi-database support from a single server
- No secrets stored in Terraform state (sensitive outputs)
- Explicit configuration via inputs
- Compatible with EPIC auto-wiring and orchestration

---

## Resources Created

This module creates the following Azure resources:

- azurerm_mssql_server
- azurerm_mssql_database (one per entry in `databases`)
- azurerm_mssql_firewall_rule (one per entry in `firewall_rules`)
- random_password (when admin_password is not provided)

No networking, logging, or monitoring resources are created directly.

---

## Security Defaults

The following controls are enforced automatically:

- TLS 1.2 minimum
- Public network access disabled
- Password auto-generation (24 characters) when not explicitly provided
- Sensitive password output

---

## Inputs

### Required Inputs

| Name | Description |
|------|-------------|
| tenant_id | Target tenant |
| subscription_id | Target subscription |
| resource_group_name | Target resource group |
| azure_region | Azure region |
| server_name | SQL Server name |
| tags | Resource tags |

---

### Server Configuration

| Name | Description | Default |
|------|-------------|---------|
| sql_version | SQL Server version | 12.0 |
| admin_username | Administrator login username | epicadmin |
| admin_password | Administrator login password (auto-generated if null) | null |
| minimum_tls_version | Minimum TLS version | 1.2 |
| public_network_access_enabled | Whether public network access is enabled | false |
| enable_auditing | Enable auditing on the SQL Server | false |

---

### Azure AD Authentication

| Name | Description | Default |
|------|-------------|---------|
| azuread_admin | Azure AD administrator (object with login_username and object_id) | null |

---

### Database Configuration

| Name | Description | Default |
|------|-------------|---------|
| databases | List of databases to create (name, sku_name, max_size_gb, zone_redundant) | [] |
| firewall_rules | List of firewall rules (name, start_ip, end_ip) | [] |

Database object defaults: sku_name = "S0", max_size_gb = 2, zone_redundant = false.

---

## Outputs

| Name | Description |
|------|-------------|
| server_id | SQL Server resource ID |
| server_name | SQL Server name |
| server_fqdn | Fully qualified domain name |
| admin_username | Administrator login username |
| admin_password | Administrator login password (sensitive) |
| database_ids | Map of database name to database ID |

---

## Example Usage (Direct Terraform)

### Basic SQL Server with a single database

```hcl
module "sql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-sql.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-dev"
  azure_region        = "westus"

  server_name = "sql-example-dev"

  databases = [
    {
      name        = "appdb"
      sku_name    = "S0"
      max_size_gb = 5
    }
  ]

  tags = {
    owner = "team-x"
  }
}
```

### SQL Server with Azure AD admin and firewall rules

```hcl
module "sql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-sql.git"

  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  resource_group_name = "rg-example-prod"
  azure_region        = "westus"

  server_name = "sql-example-prod"

  azuread_admin = {
    login_username = "sqladmin@pge.com"
    object_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }

  databases = [
    {
      name           = "appdb"
      sku_name       = "S1"
      max_size_gb    = 50
      zone_redundant = true
    },
    {
      name = "reportdb"
    }
  ]

  firewall_rules = [
    {
      name     = "allow-azure-services"
      start_ip = "0.0.0.0"
      end_ip   = "0.0.0.0"
    }
  ]

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
  - name: sql
    path: epic-pipeline-module-azure-sql
    variables:
      server_name: "sql-example-dev"
      databases:
        - name: appdb
          sku_name: S0
          max_size_gb: 5

      tags: module.tags.tags
```

---

## Module Composition Pattern

Higher-level modules should follow this pattern:

```hcl
module "sql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-sql.git"

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region
  server_name         = var.server_name

  databases      = var.databases
  firewall_rules = var.firewall_rules
}
```

Additional concerns (monitoring, networking, private endpoints) should be layered **outside** this module.

---

## Terraform Compatibility

- Terraform >= 1.5
- AzureRM Provider >= 3.100

---

## Why This Module Exists

This module exists to:

- Standardize Azure SQL Database deployments
- Remove copy-paste infrastructure definitions
- Enforce consistent security defaults
- Provide a SQL Server option alongside PostgreSQL
- Serve as the canonical EPIC SQL Database primitive

It is **infrastructure**, not deployment logic.

---

## Ownership

Maintained by:
**PG&E Enterprise Cloud & DevSecOps**

Part of the **EPIC (Enterprise Pipeline for Infrastructure & Cloud)** ecosystem.

---

## Final Notes

If you need:

- Elastic pools
- Geo-replication
- Private endpoints
- Advanced threat protection
- Long-term backup retention

Use or compose a **higher-level EPIC module** that builds on this foundation.

This module should remain **clean, minimal, and security-first**.
