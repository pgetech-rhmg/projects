# EPIC Module — Azure PostgreSQL Flexible Server

## Overview

Provisions an Azure Database for PostgreSQL Flexible Server with optional databases, firewall rules, and VNet integration. Designed to be consumed from an application's `.infra/` Terraform layout when EPIC provisions infrastructure as part of a pipeline run driven by `.pipeline/epic.json`.

The module accepts a generated administrator password by default (returned as a sensitive output) and can attach to a delegated subnet with a private DNS zone for private networking.

## Resources

- `azurerm_postgresql_flexible_server.this` — the Flexible Server
- `azurerm_postgresql_flexible_server_database.this` — one per entry in `databases`
- `azurerm_postgresql_flexible_server_firewall_rule.this` — one per entry in `firewall_rules`
- `random_password.admin` — generated when `admin_password` is null

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Name of the resource group |
| `azure_region` | `string` | Azure region |
| `server_name` | `string` | Name of the PostgreSQL Flexible Server |
| `tags` | `map(string)` | Resource tags |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `postgresql_version` | `string` | `"16"` | PostgreSQL major version. One of `13`, `14`, `15`, `16` |
| `sku_name` | `string` | `"B_Standard_B1ms"` | Flexible Server SKU (e.g. `B_Standard_B1ms`, `GP_Standard_D2s_v3`, `MO_Standard_E4s_v3`) |
| `storage_mb` | `number` | `32768` | Storage in MB |
| `storage_tier` | `string` | `"P4"` | Storage performance tier |
| `backup_retention_days` | `number` | `7` | Backup retention in days (7–35) |
| `geo_redundant_backup_enabled` | `bool` | `false` | Enable geo-redundant backups |
| `zone` | `string` | `null` | Availability zone (`1`, `2`, or `3`) |
| `admin_username` | `string` | `"epicadmin"` | Administrator login name |
| `admin_password` | `string` | `null` | Administrator password. If null, a 24-character password is auto-generated |
| `databases` | `list(object)` | `[]` | Databases to create. Each: `{ name, charset = "UTF8", collation = "en_US.utf8" }` |
| `firewall_rules` | `list(object)` | `[]` | Public-access firewall rules. Each: `{ name, start_ip, end_ip }` |
| `delegated_subnet_id` | `string` | `null` | Subnet ID for VNet integration |
| `private_dns_zone_id` | `string` | `null` | Private DNS zone ID for FQDN resolution |

## Outputs

| Name | Description |
|------|-------------|
| `server_id` | ID of the PostgreSQL Flexible Server |
| `server_name` | Name of the PostgreSQL Flexible Server |
| `server_fqdn` | Fully qualified domain name of the server |
| `admin_username` | Administrator login name |
| `admin_password` | Administrator password (sensitive) |
| `database_names` | List of created database names |

## Usage in a Terraform project

Consumed from `.infra/main.tf` in an application repo that uses EPIC. The module is referenced over HTTPS and pinned with `?ref=`.

No real consumer of this module exists in the workspace today; the example below is synthetic.

```hcl
module "postgres" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-postgresql.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  server_name         = "psql-my-app-dev"

  postgresql_version = "16"
  sku_name           = "GP_Standard_D2s_v3"
  storage_mb         = 65536

  databases = [
    { name = "appdb" }
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
  value = module.postgres.server_fqdn
}
```

## Usage from another module

Composable inside a higher-level wrapper (e.g. an app-stack module that also creates a resource group and App Service):

```hcl
module "postgres" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-postgresql.git?ref=main"

  resource_group_name = azurerm_resource_group.this.name
  azure_region        = azurerm_resource_group.this.location
  server_name         = "${var.app_name}-psql-${var.environment}"

  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  databases = [for db in var.databases : { name = db }]

  tags = var.tags
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 3.100` |
| `hashicorp/random` | `~> 3.5` |

## Notes

- When `admin_password` is null, the module generates a 24-character password and exposes it via the `admin_password` output (sensitive). Capture it in a Terraform output or write it to a secret store — it cannot be recovered later.
- Setting `delegated_subnet_id` and `private_dns_zone_id` switches the server to private networking. Public `firewall_rules` are not used in that mode.
- `backup_retention_days` is validated to be between 7 and 35 inclusive.
- The deploy stage does not consume any output of this module by convention. If the app needs the FQDN at deploy time, surface it via `outputs.tf` in `.infra/` so it lands in the `terraform-outputs` artifact.
