# Action Groups for PGE Operations Team
resource "azurerm_monitor_action_group" "action_groups" {
  for_each = { for idx, ag in var.action_groups : idx => ag }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  short_name          = each.value.short_name
  enabled             = each.value.enabled

  dynamic "email_receiver" {
    for_each = each.value.email_addresses
    content {
      name                    = "${each.value.short_name}-${email_receiver.key + 1}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

