# Service Bus Metric Alerts
# This file contains metric alerts for Azure Service Bus monitoring following AMBA best practices

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.servicebus_namespace_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.servicebus_namespace_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Service Bus Namespaces using static names
data "azurerm_servicebus_namespace" "servicebus_namespaces" {
  for_each            = toset(var.servicebus_namespace_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Service Bus Namespace - Incoming Requests Alert
resource "azurerm_monitor_metric_alert" "servicebus_incoming_requests" {
  count               = var.enable_servicebus_incoming_requests_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-incoming-requests-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace incoming requests count is above threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "IncomingRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_incoming_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Successful Requests Low Alert
resource "azurerm_monitor_metric_alert" "servicebus_successful_requests_low" {
  count               = var.enable_servicebus_successful_requests_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-successful-requests-low-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace successful requests count is below threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "SuccessfulRequests"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = var.servicebus_successful_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Service Bus Namespace - Server Errors Alert
resource "azurerm_monitor_metric_alert" "servicebus_server_errors" {
  count               = var.enable_servicebus_server_errors_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-server-errors-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace server errors detected"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ServerErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_server_errors_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Service Bus Namespace - User Errors Alert
resource "azurerm_monitor_metric_alert" "servicebus_user_errors" {
  count               = var.enable_servicebus_user_errors_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-user-errors-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace user errors detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "UserErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_user_errors_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Service Bus Namespace - Throttled Requests Alert
resource "azurerm_monitor_metric_alert" "servicebus_throttled_requests" {
  count               = var.enable_servicebus_throttled_requests_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-throttled-requests-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace throttled requests detected"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ThrottledRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_throttled_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Service Bus Namespace - Incoming Messages Alert
resource "azurerm_monitor_metric_alert" "servicebus_incoming_messages" {
  count               = var.enable_servicebus_incoming_messages_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-incoming-messages-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace incoming messages count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "IncomingMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_incoming_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Outgoing Messages Alert
resource "azurerm_monitor_metric_alert" "servicebus_outgoing_messages" {
  count               = var.enable_servicebus_outgoing_messages_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-outgoing-messages-low-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace outgoing messages count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "OutgoingMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_outgoing_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Active Connections Alert
resource "azurerm_monitor_metric_alert" "servicebus_active_connections" {
  count               = var.enable_servicebus_active_connections_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-active-connections-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace active connections count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ActiveConnections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.servicebus_active_connections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Connections Opened Alert
resource "azurerm_monitor_metric_alert" "servicebus_connections_opened" {
  count               = var.enable_servicebus_connections_opened_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-connections-opened-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace connections opened count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ConnectionsOpened"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_connections_opened_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Connections Closed Alert
resource "azurerm_monitor_metric_alert" "servicebus_connections_closed" {
  count               = var.enable_servicebus_connections_closed_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-connections-closed-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace connections closed count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ConnectionsClosed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.servicebus_connections_closed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Size Alert
resource "azurerm_monitor_metric_alert" "servicebus_size" {
  count               = var.enable_servicebus_size_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-size-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace size is above threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "Size"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.servicebus_size_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Active Messages Alert
resource "azurerm_monitor_metric_alert" "servicebus_active_messages" {
  count               = var.enable_servicebus_active_messages_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-active-messages-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace active messages count is above threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ActiveMessages"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.servicebus_active_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Service Bus Namespace - Dead Letter Messages Alert
resource "azurerm_monitor_metric_alert" "servicebus_dead_letter_messages" {
  count               = var.enable_servicebus_dead_letter_messages_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-dead-letter-messages-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace dead letter messages detected"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "DeadletteredMessages"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.servicebus_dead_letter_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Service Bus Namespace - Scheduled Messages Alert
resource "azurerm_monitor_metric_alert" "servicebus_scheduled_messages" {
  count               = var.enable_servicebus_scheduled_messages_alert && length(var.servicebus_namespace_names) > 0 ? 1 : 0
  name                = "servicebus-scheduled-messages-high-${join("-", var.servicebus_namespace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = [for namespace in data.azurerm_servicebus_namespace.servicebus_namespaces : namespace.id]
  description         = "Service Bus namespace scheduled messages count is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT30M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ScheduledMessages"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.servicebus_scheduled_messages_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "servicebus_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.servicebus_namespace_names) : []
  name                           = "servicebus-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_servicebus_namespace.servicebus_namespaces[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "servicebus_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.servicebus_namespace_names) : []
  name                       = "servicebus-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_servicebus_namespace.servicebus_namespaces[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
