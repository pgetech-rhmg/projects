# AMBA Alerts for Azure Firewall
# This file contains comprehensive monitoring alerts for Azure Firewall resources

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Azure Firewalls using static names
data "azurerm_firewall" "firewalls" {
  for_each            = toset(var.firewall_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Firewall Health State Alert
resource "azurerm_monitor_metric_alert" "firewall_health" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-health-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Azure Firewall health state is degraded or unhealthy"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallHealth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.firewall_health_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-health"
  })
}

# SNAT Port Utilization Alert
resource "azurerm_monitor_metric_alert" "snat_port_utilization" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-snat-utilization-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SNAT port utilization exceeds 95% indicating potential port exhaustion"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "SNATPortUtilization"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.firewall_snat_port_utilization_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-snat-utilization"
  })
}

# Firewall Throughput Alert
resource "azurerm_monitor_metric_alert" "firewall_throughput" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-throughput-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when firewall throughput is approaching maximum capacity"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "Throughput"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.firewall_throughput_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-throughput"
  })
}

# Firewall Latency Probe Alert
resource "azurerm_monitor_metric_alert" "firewall_latency" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-latency-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when firewall latency exceeds acceptable thresholds"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallLatencyPng"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.firewall_latency_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-latency"
  })
}

# Data Processed Alert
resource "azurerm_monitor_metric_alert" "data_processed" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-data-processed-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when data processed by firewall is unusually high"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "DataProcessed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.firewall_data_processed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-data-processed"
  })
}

# Application Rule Hit Count Alert
resource "azurerm_monitor_metric_alert" "application_rule_hit" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-app-rule-hit-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when application rule hit count is unusually high indicating potential issues"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "ApplicationRuleHit"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.firewall_app_rule_hit_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-app-rule-hit"
  })
}

# Network Rule Hit Count Alert
resource "azurerm_monitor_metric_alert" "network_rule_hit" {
  for_each            = data.azurerm_firewall.firewalls
  name                = "firewall-net-rule-hit-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when network rule hit count is unusually high indicating potential issues"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "NetworkRuleHit"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.firewall_net_rule_hit_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "firewall-net-rule-hit"
  })
}