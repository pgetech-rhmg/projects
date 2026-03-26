# Event Hub Metric Alerts
# This file contains metric alerts for Azure Event Hub monitoring following AMBA best practices

# Data source for current Azure client configuration
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
  # Note: For Event Hub module, eventhub_namespace_name must be specified for diagnostic settings
  # This is the DESTINATION Event Hub for logs (can be different from the namespaces being monitored)
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_namespace_name != "" && var.eventhub_name != "" && length(var.eventhub_namespace_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.eventhub_namespace_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Event Hub Namespaces using static names
data "azurerm_eventhub_namespace" "eventhub_namespaces" {
  for_each            = toset(var.eventhub_namespace_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data source to get Event Hubs using static names
data "azurerm_eventhub" "eventhubs" {
  for_each            = toset(var.eventhub_names)
  name                = each.value
  namespace_name      = var.eventhub_default_namespace
  resource_group_name = var.resource_group_name
}

# Event Hub Namespace - Incoming Requests Alert
resource "azurerm_monitor_metric_alert" "eventhub_incoming_requests" {
  count               = var.enable_eventhub_incoming_requests_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-incoming-requests-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace incoming requests count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "IncomingRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_incoming_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Successful Requests Alert (Low)
resource "azurerm_monitor_metric_alert" "eventhub_successful_requests_low" {
  count               = var.enable_eventhub_successful_requests_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-successful-requests-low-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace successful requests count is below threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "SuccessfulRequests"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = var.eventhub_successful_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Event Hub Namespace - Server Errors Alert
resource "azurerm_monitor_metric_alert" "eventhub_server_errors" {
  count               = var.enable_eventhub_server_errors_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-server-errors-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace server errors detected"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "ServerErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_server_errors_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Hub Namespace - User Errors Alert
resource "azurerm_monitor_metric_alert" "eventhub_user_errors" {
  count               = var.enable_eventhub_user_errors_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-user-errors-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace user errors detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "UserErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_user_errors_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Hub Namespace - Throttled Requests Alert
resource "azurerm_monitor_metric_alert" "eventhub_throttled_requests" {
  count               = var.enable_eventhub_throttled_requests_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-throttled-requests-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace throttled requests detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "ThrottledRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_throttled_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Event Hub Namespace - Incoming Messages Alert
resource "azurerm_monitor_metric_alert" "eventhub_incoming_messages" {
  count               = var.enable_eventhub_incoming_messages_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-incoming-messages-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace incoming messages count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "IncomingMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_incoming_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Outgoing Messages Alert
resource "azurerm_monitor_metric_alert" "eventhub_outgoing_messages" {
  count               = var.enable_eventhub_outgoing_messages_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-outgoing-messages-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace outgoing messages count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "OutgoingMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_outgoing_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Incoming Bytes Alert
resource "azurerm_monitor_metric_alert" "eventhub_incoming_bytes" {
  count               = var.enable_eventhub_incoming_bytes_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-incoming-bytes-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace incoming bytes is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "IncomingBytes"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_incoming_bytes_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Outgoing Bytes Alert
resource "azurerm_monitor_metric_alert" "eventhub_outgoing_bytes" {
  count               = var.enable_eventhub_outgoing_bytes_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-outgoing-bytes-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace outgoing bytes is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "OutgoingBytes"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_outgoing_bytes_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Active Connections Alert
resource "azurerm_monitor_metric_alert" "eventhub_active_connections" {
  count               = var.enable_eventhub_active_connections_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-active-connections-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace active connections count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "ActiveConnections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.eventhub_active_connections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Connections Opened Alert
resource "azurerm_monitor_metric_alert" "eventhub_connections_opened" {
  count               = var.enable_eventhub_connections_opened_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-connections-opened-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace connections opened count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "ConnectionsOpened"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_connections_opened_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Connections Closed Alert
resource "azurerm_monitor_metric_alert" "eventhub_connections_closed" {
  count               = var.enable_eventhub_connections_closed_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-connections-closed-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace connections closed count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "ConnectionsClosed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_connections_closed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Event Hub Namespace - Quota Exceeded Errors Alert
resource "azurerm_monitor_metric_alert" "eventhub_quota_exceeded_errors" {
  count               = var.enable_eventhub_quota_exceeded_alert && length(var.eventhub_namespace_names) > 0 ? 1 : 0
  name                = "eventhub-quota-exceeded-errors-high-${join("-", var.eventhub_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_eventhub_namespace.eventhub_namespaces : namespace.id]
  description         = "Event Hub namespace quota exceeded errors detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "QuotaExceededErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.eventhub_quota_exceeded_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Event Hub - Size Alert (Individual Event Hub)
resource "azurerm_monitor_metric_alert" "eventhub_size" {
  count               = var.enable_eventhub_size_alert && length(var.eventhub_names) > 0 && var.eventhub_default_namespace != "" ? 1 : 0
  name                = "eventhub-size-high-${join("-", var.eventhub_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for eh in data.azurerm_eventhub.eventhubs : eh.id]
  description         = "Event Hub size is above threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.EventHub/namespaces"
    metric_name      = "Size"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.eventhub_size_threshold

    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = var.eventhub_names
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: Event Hub Namespace - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "eventhub_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? data.azurerm_eventhub_namespace.eventhub_namespaces : {}
  name               = "eventhub-activity-logs-to-eventhub-${each.value.name}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Event Hub operations
  enabled_log {
    category = "ArchiveLogs"
  }

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "AutoScaleLogs"
  }

  enabled_log {
    category = "KafkaCoordinatorLogs"
  }

  enabled_log {
    category = "KafkaUserErrorLogs"
  }

  enabled_log {
    category = "EventHubVNetConnectionEvent"
  }

  enabled_log {
    category = "CustomerManagedKeyUserLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Event Hub Namespace - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "eventhub_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? data.azurerm_eventhub_namespace.eventhub_namespaces : {}
  name               = "eventhub-security-logs-to-loganalytics-${each.value.name}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "ArchiveLogs"
  }

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "AutoScaleLogs"
  }

  enabled_log {
    category = "KafkaCoordinatorLogs"
  }

  enabled_log {
    category = "KafkaUserErrorLogs"
  }

  enabled_log {
    category = "EventHubVNetConnectionEvent"
  }

  enabled_log {
    category = "CustomerManagedKeyUserLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
