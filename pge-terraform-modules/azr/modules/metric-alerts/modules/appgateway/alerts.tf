# AMBA Alerts for Azure Application Gateway
# This file contains comprehensive monitoring alerts for Azure Application Gateway resources

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.application_gateway_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.application_gateway_names) > 0
}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Application Gateways using static names
data "azurerm_application_gateway" "app_gateways" {
  for_each            = toset(var.application_gateway_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Compute Unit Utilization Alert (v2 SKU)
resource "azurerm_monitor_metric_alert" "compute_unit_utilization" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-compute-unit-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Gateway compute unit utilization exceeds 75% of average usage"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "ComputeUnits"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_compute_unit_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-compute-unit"
  })
}

# Capacity Unit Utilization Alert (v2 SKU)
resource "azurerm_monitor_metric_alert" "capacity_unit_utilization" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-capacity-unit-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Gateway capacity unit utilization exceeds 75% of peak usage"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "CapacityUnits"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_capacity_unit_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-capacity-unit"
  })
}

# Unhealthy Host Count Alert
resource "azurerm_monitor_metric_alert" "unhealthy_host_count" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-unhealthy-hosts-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when backend servers are unhealthy (exceeds 20% of backend capacity)"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_unhealthy_host_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-unhealthy-hosts"
  })
}

# Response Status 4xx Alert
resource "azurerm_monitor_metric_alert" "response_status_4xx" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-response-4xx-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Gateway returns 4xx client errors"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "ResponseStatus"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.appgw_response_4xx_threshold

    dimension {
      name     = "HttpStatusGroup"
      operator = "Include"
      values   = ["4xx"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-response-4xx"
  })
}

# Response Status 5xx Alert
resource "azurerm_monitor_metric_alert" "response_status_5xx" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-response-5xx-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Gateway returns 5xx server errors"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "ResponseStatus"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.appgw_response_5xx_threshold

    dimension {
      name     = "HttpStatusGroup"
      operator = "Include"
      values   = ["5xx"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-response-5xx"
  })
}

# Failed Requests Alert
resource "azurerm_monitor_metric_alert" "failed_requests" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-failed-requests-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when failed request count exceeds threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "FailedRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.appgw_failed_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-failed-requests"
  })
}

# Backend Last Byte Response Time Alert
resource "azurerm_monitor_metric_alert" "backend_response_time" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-backend-response-time-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when backend last byte response time exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "BackendLastByteResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_backend_response_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-backend-response-time"
  })
}

# Application Gateway Total Time Alert
resource "azurerm_monitor_metric_alert" "application_gateway_total_time" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-total-time-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Gateway total processing time exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "ApplicationGatewayTotalTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_total_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-total-time"
  })
}

# Backend Connect Time Alert
resource "azurerm_monitor_metric_alert" "backend_connect_time" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-backend-connect-time-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when backend connection establishment time is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "BackendConnectTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_backend_connect_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-backend-connect-time"
  })
}

# Throughput Alert
resource "azurerm_monitor_metric_alert" "throughput" {
  for_each            = data.azurerm_application_gateway.app_gateways
  name                = "appgw-throughput-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when throughput is unusually high indicating potential capacity issues"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "Throughput"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.appgw_throughput_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "appgw-throughput"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Application Gateway Logs to Event Hub for external SIEM integration
resource "azurerm_monitor_diagnostic_setting" "appgw_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.application_gateway_names) : []

  name                           = "send-appgw-logs-to-eventhub"
  target_resource_id             = data.azurerm_application_gateway.app_gateways[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Application Gateway Log Categories
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
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

# Send Application Gateway Security Logs to Log Analytics Workspace for analysis
resource "azurerm_monitor_diagnostic_setting" "appgw_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.application_gateway_names) : []

  name                       = "send-appgw-logs-to-loganalytics"
  target_resource_id         = data.azurerm_application_gateway.app_gateways[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Application Gateway Log Categories - Security focused
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
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
