# EPIC Azure Log Analytics Module

## Overview

`epic-pipeline-module-azure-log-analytics` provisions an Azure Log Analytics workspace as a reusable building block for EPIC-managed Azure infrastructure.

It is the monitoring backing store for other EPIC Azure modules — most notably `epic-pipeline-module-azure-container-app`, whose Container App Environment requires a workspace ID. It is intended to be consumed from an application's `.infra/` Terraform directory or composed into a higher-level EPIC module.

---

## Resources Created

- `azurerm_log_analytics_workspace`

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group the workspace is created in. |
| `azure_region` | `string` | Azure region for the workspace. |
| `workspace_name` | `string` | Name of the Log Analytics workspace. |
| `tags` | `map(string)` | Resource tags applied to the workspace. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sku` | `string` | `PerGB2018` | Pricing SKU for the workspace. |
| `retention_in_days` | `number` | `30` | Data retention in days (30-730). PG&E BIA tiers may require higher retention (Tier 1 = 365). |
| `internet_ingestion_enabled` | `bool` | `true` | Whether logs may be ingested from the public internet. |
| `internet_query_enabled` | `bool` | `true` | Whether the workspace may be queried from the public internet. |

---

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `workspace_id` | No | Resource ID of the workspace (pass to Container App Environment, diagnostic settings, etc.). |
| `workspace_name` | No | Name of the workspace. |
| `workspace_customer_id` | No | Workspace (customer) ID used by agents. |
| `primary_shared_key` | Yes | Primary shared key for the workspace. |

---

## Usage in a Terraform Project

```hcl
module "log_analytics" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-log-analytics.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  workspace_name      = "log-my-app-dev"

  tags = module.tags.tags
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- The default 30-day retention satisfies the SECURITY-14/-15 control intent (minimum 30-day retention). Raise `retention_in_days` per the application's BIA tier.
- `internet_ingestion_enabled` / `internet_query_enabled` default to `true` to match Azure defaults. Set both to `false` and pair with private-link scoping for the SECURITY-05 (no-public-access) control intent.
