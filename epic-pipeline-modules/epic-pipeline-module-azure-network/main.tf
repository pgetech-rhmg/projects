resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  address_space = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Subnet delegation (e.g. delegating a subnet to a PaaS service such as a
  # Container App Environment or PostgreSQL Flexible Server).
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.service_delegation_actions
      }
    }
  }
}

resource "azurerm_public_ip" "this" {
  for_each = { for p in var.public_ips : p.name => p }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  allocation_method = each.value.allocation_method
  sku               = each.value.sku
  zones             = each.value.zones

  tags = var.tags
}
