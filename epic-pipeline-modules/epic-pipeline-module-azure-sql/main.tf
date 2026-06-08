resource "random_password" "admin" {
  count   = local.generate_password ? 1 : 0
  length  = 24
  special = true
}

resource "azurerm_mssql_server" "this" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  version             = var.sql_version

  administrator_login          = var.admin_username
  administrator_login_password = local.generate_password ? random_password.admin[0].result : var.admin_password

  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "azuread_administrator" {
    for_each = var.azuread_admin != null ? [var.azuread_admin] : []
    content {
      login_username = azuread_administrator.value.login_username
      object_id      = azuread_administrator.value.object_id
    }
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  for_each = { for db in var.databases : db.name => db }

  name         = each.value.name
  server_id    = azurerm_mssql_server.this.id
  sku_name     = each.value.sku_name
  max_size_gb  = each.value.max_size_gb
  zone_redundant = each.value.zone_redundant

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name             = each.value.name
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
