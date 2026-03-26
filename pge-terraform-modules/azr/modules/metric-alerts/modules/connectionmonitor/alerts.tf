# AMBA Alerts for Azure Connection Monitor
# This file contains comprehensive monitoring alerts for Azure Connection Monitor resources
# Note: Connection Monitor does NOT support diagnostic settings. Data is sent directly to 
# the Log Analytics workspace configured in the Connection Monitor itself.

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Local variables for Connection Monitor mapping
locals {
  # Create a simple map of Connection Monitor names to resource IDs
  # Users must provide full resource IDs via connection_monitor_ids variable
  connection_monitor_map = { for id in var.connection_monitor_ids : basename(id) => id }
}

#====================================================================================================
# CONNECTIVITY CHECKS FAILED ALERTS
#====================================================================================================

# Warning: High Percentage of Failed Checks
resource "azurerm_monitor_metric_alert" "checks_failed_warning" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-checks-failed-warning-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Alert when connectivity checks exceed ${var.checks_failed_threshold}% failure rate"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "ChecksFailedPercent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.checks_failed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-checks-failed-warning"
  })
}

# Critical: Very High Percentage of Failed Checks
resource "azurerm_monitor_metric_alert" "checks_failed_critical" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-checks-failed-critical-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Critical alert when connectivity checks exceed ${var.checks_failed_critical_threshold}% failure rate"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "ChecksFailedPercent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.checks_failed_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-checks-failed-critical"
  })
}

#====================================================================================================
# NETWORK LATENCY ALERTS
#====================================================================================================

# Warning: High Round-Trip Time (Latency)
resource "azurerm_monitor_metric_alert" "latency_warning" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-latency-warning-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Alert when round-trip time exceeds ${var.latency_threshold_ms}ms"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "RoundTripTimeMs"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.latency_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-latency-warning"
  })
}

# Critical: Very High Round-Trip Time (Latency)
resource "azurerm_monitor_metric_alert" "latency_critical" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-latency-critical-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Critical alert when round-trip time exceeds ${var.latency_critical_threshold_ms}ms"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "RoundTripTimeMs"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.latency_critical_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-latency-critical"
  })
}

#====================================================================================================
# TEST RESULT ALERTS
#====================================================================================================

# Test Result Failed Alert
resource "azurerm_monitor_metric_alert" "test_result_failed" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-test-failed-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Alert when connection monitor test fails (TestResult = 3)"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "TestResult"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 3 # 0=Indeterminate, 1=Pass, 2=Warning, 3=Fail
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-test-failed"
  })
}

# Test Result Warning Alert
resource "azurerm_monitor_metric_alert" "test_result_warning" {
  for_each            = local.connection_monitor_map
  name                = "conn-monitor-test-warning-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  description         = "Alert when connection monitor test shows warning (TestResult = 2)"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/networkWatchers/connectionMonitors"
    metric_name      = "TestResult"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 2 # 0=Indeterminate, 1=Pass, 2=Warning, 3=Fail
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "connection-monitor-test-warning"
  })
}
