# AMBA Alerts for Azure Private DNS Zones
# This file contains monitoring alerts for Azure Private DNS Zones (e.g., App Service Environment zones)

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Private DNS zones
data "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.dns_zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Private DNS Zone Record Set Count Alert
resource "azurerm_monitor_metric_alert" "dns_record_set_count" {
  for_each            = data.azurerm_private_dns_zone.zones
  name                = "private-dns-recordset-count-${replace(each.key, ".", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Private DNS zone ${each.key} record set count reaches high levels"
  severity            = 3
  frequency           = "PT1H"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/privateDnsZones"
    metric_name      = "RecordSetCount"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 25000 # Private DNS zones have higher limits than public
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "private-dns-recordset-count"
    dns_zone   = each.key
  })
}

# Activity Log Alert - Private DNS Zone Configuration Changes
resource "azurerm_monitor_activity_log_alert" "private_dns_zone_configuration_change" {
  count               = length(var.dns_zone_names) > 0 ? 1 : 0
  name                = "private-dns-zone-configuration-change-${join("-", [for zone in var.dns_zone_names : replace(zone, ".", "-")])}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for zone in data.azurerm_private_dns_zone.zones : zone.id]
  description         = "Alert when Private DNS zone configuration is changed"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Network"
    resource_type     = "Microsoft.Network/privateDnsZones"
    operation_name    = "Microsoft.Network/privateDnsZones/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "private-dns-zone-configuration-change"
  })
}

# Activity Log Alert - Private DNS Zone Deletion
resource "azurerm_monitor_activity_log_alert" "private_dns_zone_deletion" {
  count               = length(var.dns_zone_names) > 0 ? 1 : 0
  name                = "private-dns-zone-deletion-${join("-", [for zone in var.dns_zone_names : replace(zone, ".", "-")])}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for zone in data.azurerm_private_dns_zone.zones : zone.id]
  description         = "Alert when Private DNS zone is deleted"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Network"
    resource_type     = "Microsoft.Network/privateDnsZones"
    operation_name    = "Microsoft.Network/privateDnsZones/delete"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "private-dns-zone-deletion"
  })
}


