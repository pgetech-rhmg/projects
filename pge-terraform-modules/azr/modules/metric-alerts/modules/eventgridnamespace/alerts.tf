# Event Grid Namespace Metric Alerts
# This file contains metric alerts for Azure Event Grid Namespace monitoring following AMBA best practices

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Local variables to construct Event Grid Namespace resource IDs
locals {
  eventgrid_namespace_ids = [
    for name in var.eventgrid_namespace_names :
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.EventGrid/namespaces/${name}"
  ]

  # Map of namespace names to IDs for diagnostic settings
  eventgrid_namespace_map = {
    for name in var.eventgrid_namespace_names :
    name => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.EventGrid/namespaces/${name}"
  }

  # Subscription IDs with fallback to current subscription
  eventhub_subscription_id      = var.eventhub_subscription_id != "" ? var.eventhub_subscription_id : data.azurerm_client_config.current.subscription_id
  log_analytics_subscription_id = var.log_analytics_subscription_id != "" ? var.log_analytics_subscription_id : data.azurerm_client_config.current.subscription_id

  # Full resource IDs for cross-subscription support
  eventhub_namespace_id      = "/subscriptions/${local.eventhub_subscription_id}/resourceGroups/${var.eventhub_resource_group_name}/providers/Microsoft.EventHub/namespaces/${var.eventhub_namespace_name}"
  eventhub_id                = "${local.eventhub_namespace_id}/eventhubs/${var.eventhub_name}"
  eventhub_auth_rule_id      = "${local.eventhub_namespace_id}/authorizationRules/${var.eventhub_authorization_rule_name}"
  log_analytics_workspace_id = "/subscriptions/${local.log_analytics_subscription_id}/resourceGroups/${var.log_analytics_resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"

  # Conditional flags for diagnostic settings
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings
}

# Data source to get current Azure subscription
data "azurerm_client_config" "current" {}

# Event Grid Namespace - MQTT Successful Published Messages Alert
resource "azurerm_monitor_metric_alert" "eventgrid_mqtt_published_messages" {
  count               = var.enable_eventgrid_mqtt_published_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-mqtt-published-high-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace MQTT published messages count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "Mqtt.SuccessfulPublishedMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_mqtt_published_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Grid Namespace - MQTT Failed Published Messages Alert
resource "azurerm_monitor_metric_alert" "eventgrid_mqtt_failed_published" {
  count               = var.enable_eventgrid_mqtt_failed_published_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-mqtt-publish-failed-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace MQTT publish failed messages detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "Mqtt.FailedPublishedMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_mqtt_failed_published_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Grid Namespace - MQTT Connections Alert
resource "azurerm_monitor_metric_alert" "eventgrid_mqtt_connections" {
  count               = var.enable_eventgrid_mqtt_connections_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-mqtt-connections-high-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace MQTT active connections count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "Mqtt.Connections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_mqtt_connections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Grid Namespace - HTTP Successful Published Events Alert
resource "azurerm_monitor_metric_alert" "eventgrid_http_published_events" {
  count               = var.enable_eventgrid_http_published_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-http-published-high-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace HTTP published events count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "SuccessfulPublishedEvents"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_http_published_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Grid Namespace - HTTP Failed Published Events Alert
resource "azurerm_monitor_metric_alert" "eventgrid_http_failed_published" {
  count               = var.enable_eventgrid_http_failed_published_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-http-publish-failed-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace HTTP publish failed events detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "FailedPublishedEvents"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_http_failed_published_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Grid Namespace - Delivery Attempts Failed Alert
resource "azurerm_monitor_metric_alert" "eventgrid_delivery_attempts_failed" {
  count               = var.enable_eventgrid_delivery_attempts_failed_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-delivery-attempts-failed-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace delivery attempts failed detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "FailedAcknowledgedEvents"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_delivery_attempts_failed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Grid Namespace - Delivery Attempts Succeeded Alert
resource "azurerm_monitor_metric_alert" "eventgrid_delivery_attempts_succeeded" {
  count               = var.enable_eventgrid_delivery_attempts_succeeded_alert && length(var.eventgrid_namespace_names) > 0 ? 1 : 0
  name                = "eventgrid-namespace-delivery-attempts-succeeded-${join("-", var.eventgrid_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.eventgrid_namespace_ids
  description         = "Event Grid namespace delivery attempts succeeded"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventGrid/namespaces"
    metric_name      = "SuccessfulAcknowledgedEvents"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventgrid_delivery_attempts_succeeded_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# ========================================
# DIAGNOSTIC SETTINGS
# ========================================

# Diagnostic Setting 1: Event Grid Namespace - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "eventgrid_namespace_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? local.eventgrid_namespace_map : {}
  name               = "eventgrid-namespace-activity-logs-to-eventhub-${each.key}"
  target_resource_id = each.value

  # Send activity logs to Event Hub (supports cross-subscription)
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Event Grid Namespace operations
  enabled_log {
    category = "SuccessfulMqttConnections"
  }

  enabled_log {
    category = "FailedMqttConnections"
  }

  enabled_log {
    category = "MqttDisconnections"
  }

  enabled_log {
    category = "FailedMqttPublishedMessages"
  }

  enabled_log {
    category = "FailedMqttSubscriptionOperations"
  }

  enabled_log {
    category = "SuccessfulHttpDataPlaneOperations"
  }

  enabled_log {
    category = "FailedHttpDataPlaneOperations"
  }

  # Metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Event Grid Namespace - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "eventgrid_namespace_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? local.eventgrid_namespace_map : {}
  name               = "eventgrid-namespace-security-logs-to-loganalytics-${each.key}"
  target_resource_id = each.value

  # Send security logs to Log Analytics (supports cross-subscription)
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "SuccessfulMqttConnections"
  }

  enabled_log {
    category = "FailedMqttConnections"
  }

  enabled_log {
    category = "MqttDisconnections"
  }

  enabled_log {
    category = "FailedMqttPublishedMessages"
  }

  enabled_log {
    category = "FailedMqttSubscriptionOperations"
  }

  enabled_log {
    category = "SuccessfulHttpDataPlaneOperations"
  }

  enabled_log {
    category = "FailedHttpDataPlaneOperations"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
