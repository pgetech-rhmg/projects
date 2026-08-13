resource "azurerm_servicebus_namespace" "this" {
  name                = var.namespace_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  sku      = var.sku
  capacity = var.capacity

  tags = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = { for q in var.queues : q.name => q }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_delivery_count                   = each.value.max_delivery_count
  lock_duration                        = each.value.lock_duration
  default_message_ttl                  = each.value.default_message_ttl
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
  requires_session                     = each.value.requires_session
  max_size_in_megabytes                = each.value.max_size_in_megabytes
}
