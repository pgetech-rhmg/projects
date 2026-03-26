# AMBA Alerts for Azure Virtual Network (VNet)
# This file contains comprehensive monitoring alerts for Azure VNet and related networking components

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Local variables for cross-subscription support
locals {
  # Cross-subscription support for Event Hub and Log Analytics
  eventhub_subscription_id      = var.eventhub_subscription_id != "" ? var.eventhub_subscription_id : data.azurerm_client_config.current.subscription_id
  log_analytics_subscription_id = var.log_analytics_subscription_id != "" ? var.log_analytics_subscription_id : data.azurerm_client_config.current.subscription_id
  eventhub_resource_group       = var.eventhub_resource_group_name != "" ? var.eventhub_resource_group_name : var.resource_group_name
  log_analytics_resource_group  = var.log_analytics_resource_group_name != "" ? var.log_analytics_resource_group_name : var.resource_group_name

  # Construct full resource IDs for cross-subscription support
  eventhub_namespace_id      = "/subscriptions/${local.eventhub_subscription_id}/resourceGroups/${local.eventhub_resource_group}/providers/Microsoft.EventHub/namespaces/${var.eventhub_namespace_name}"
  eventhub_id                = "${local.eventhub_namespace_id}/eventhubs/${var.eventhub_name}"
  eventhub_auth_rule_id      = "${local.eventhub_namespace_id}/authorizationRules/${var.eventhub_authorization_rule_name}"
  log_analytics_workspace_id = "/subscriptions/${local.log_analytics_subscription_id}/resourceGroups/${local.log_analytics_resource_group}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"

  # Simplified diagnostic settings flags
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.vnet_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.vnet_names) > 0
}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Virtual Networks using static names
data "azurerm_virtual_network" "vnets" {
  for_each            = toset(var.vnet_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# VNet IfUnderDDoSAttack Alert
resource "azurerm_monitor_metric_alert" "if_under_DDOS_Attack" {
  for_each            = data.azurerm_virtual_network.vnets
  name                = "if_under_DDOS_Attack-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert if VNet is under a DDoS attack"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/virtualNetworks"
    metric_name      = "IfUnderDDoSAttack"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.vnet_if_under_ddos_attack_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vnet-if-under-ddos-attack"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Virtual Network Logs to Event Hub for external SIEM integration
resource "azurerm_monitor_diagnostic_setting" "vnet_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.vnet_names) : []

  name                           = "send-vnet-logs-to-eventhub"
  target_resource_id             = data.azurerm_virtual_network.vnets[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Virtual Network Log Categories
  enabled_log {
    category = "VMProtectionAlerts"
  }

  # Metrics disabled for Event Hub destination
  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    ignore_changes = [
      eventhub_name,
      eventhub_authorization_rule_id,
    ]
  }
}

# Send Virtual Network Security Logs to Log Analytics Workspace for analysis
resource "azurerm_monitor_diagnostic_setting" "vnet_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.vnet_names) : []

  name                       = "send-vnet-logs-to-loganalytics"
  target_resource_id         = data.azurerm_virtual_network.vnets[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Virtual Network Log Categories
  enabled_log {
    category = "VMProtectionAlerts"
  }

  # Metrics for Log Analytics
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      log_analytics_workspace_id,
    ]
  }
}

