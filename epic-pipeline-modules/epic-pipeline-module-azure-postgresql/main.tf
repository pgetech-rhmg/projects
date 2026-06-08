resource "random_password" "admin" {
  count   = local.generate_password ? 1 : 0
  length  = 24
  special = true
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  version  = var.postgresql_version
  sku_name = var.sku_name

  storage_mb   = var.storage_mb
  storage_tier = var.storage_tier

  administrator_login    = var.admin_username
  administrator_password = local.generate_password ? random_password.admin[0].result : var.admin_password

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  zone = var.zone

  authentication {
    password_auth_enabled = true
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = { for db in var.databases : db.name => db }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = each.value.charset
  collation = each.value.collation
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name             = each.value.name
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
