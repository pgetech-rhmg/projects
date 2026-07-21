# EPIC Module — Azure SQL Server

## Overview

Provisions an Azure SQL Server with optional databases and firewall rules. Designed to be consumed from an application's `.infra/` Terraform layout when EPIC provisions infrastructure as part of a pipeline run driven by `.pipeline/epic.json`.

The module accepts a generated administrator password by default (returned as a sensitive output) and optionally configures an Azure AD administrator on the server.

## Resources

- `azurerm_mssql_server.this` — the SQL Server
- `azurerm_mssql_database.this` — one per entry in `databases`
- `azurerm_mssql_firewall_rule.this` — one per entry in `firewall_rules`
- `random_password.admin` — generated when `admin_password` is null

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group |
| `azure_region` | `string` | Azure region |
| `server_name` | `string` | Name of the SQL Server |
| `tags` | `map(string)` | Resource tags |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sql_version` | `string` | `"12.0"` | SQL Server version |
| `admin_username` | `string` | `"epicadmin"` | Administrator login username |
| `admin_password` | `string` | `null` | Administrator login password. If null, a 24-character password is auto-generated |
| `minimum_tls_version` | `string` | `"1.2"` | Minimum TLS version |
| `public_network_access_enabled` | `bool` | `false` | Whether public network access is enabled |
| `azuread_admin` | `object` | `null` | Azure AD administrator. Shape: `{ login_username, object_id }` |
| `databases` | `list(object)` | `[]` | Databases to create. Each: `{ name, sku_name = "S0", max_size_gb = 2, zone_redundant = false }` |
| `firewall_rules` | `list(object)` | `[]` | Firewall rules to create. Each: `{ name, start_ip, end_ip }` |
| `enable_auditing` | `bool` | `false` | Enable auditing on the SQL Server |

## Outputs

| Name | Description |
|------|-------------|
| `server_id` | ID of the SQL Server |
| `server_name` | Name of the SQL Server |
| `server_fqdn` | Fully qualified domain name of the SQL Server |
| `admin_username` | Administrator login username |
| `admin_password` | Administrator login password (sensitive) |
| `database_ids` | Map of database name to database ID |

## Usage in a Terraform project

Consumed from `.infra/main.tf` in an application repo that uses EPIC. The module is referenced over HTTPS and pinned with `?ref=`.

No real consumer of this module exists in the workspace today; the example below is synthetic.

```hcl
module "sql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-sql.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  server_name         = "sql-my-app-dev"

  databases = [
    { name = "appdb", sku_name = "S1", max_size_gb = 10 }
  ]

  firewall_rules = [
    { name = "allow-azure-services", start_ip = "0.0.0.0", end_ip = "0.0.0.0" }
  ]

  tags = {
    application = "my-app"
    environment = "dev"
  }
}

output "app_db_fqdn" {
  value = module.sql.server_fqdn
}
```

## Usage from another module

Composable inside a higher-level wrapper (e.g. an app-stack module that also creates a resource group and App Service):

```hcl
module "sql" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-sql.git?ref=main"

  resource_group_name = azurerm_resource_group.this.name
  azure_region        = azurerm_resource_group.this.location
  server_name         = "${var.app_name}-sql-${var.environment}"

  azuread_admin = {
    login_username = var.dba_group_name
    object_id      = var.dba_group_object_id
  }

  databases = [for db in var.databases : { name = db }]

  tags = var.tags
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |
| `hashicorp/random` | `~> 3.5` |

## Notes

- When `admin_password` is null, the module generates a 24-character password and exposes it via the `admin_password` output (sensitive). Capture it in a Terraform output or write it to a secret store — it cannot be recovered later.
- `public_network_access_enabled` defaults to `false`. Public `firewall_rules` are only effective when this is set to `true`.
- The deploy stage does not consume any output of this module by convention. If the app needs the FQDN at deploy time, surface it via `outputs.tf` in `.infra/` so it lands in the `terraform-outputs` artifact.
