output "alert_ids" {
  description = "Map of alert resource IDs keyed by alert type"
  value = {
    incoming_requests       = try(azurerm_monitor_metric_alert.servicebus_incoming_requests[*].id, [])
    successful_requests_low = try(azurerm_monitor_metric_alert.servicebus_successful_requests_low[*].id, [])
    server_errors           = try(azurerm_monitor_metric_alert.servicebus_server_errors[*].id, [])
    user_errors             = try(azurerm_monitor_metric_alert.servicebus_user_errors[*].id, [])
    throttled_requests      = try(azurerm_monitor_metric_alert.servicebus_throttled_requests[*].id, [])
    incoming_messages       = try(azurerm_monitor_metric_alert.servicebus_incoming_messages[*].id, [])
    outgoing_messages       = try(azurerm_monitor_metric_alert.servicebus_outgoing_messages[*].id, [])
    active_connections      = try(azurerm_monitor_metric_alert.servicebus_active_connections[*].id, [])
    connections_opened      = try(azurerm_monitor_metric_alert.servicebus_connections_opened[*].id, [])
    connections_closed      = try(azurerm_monitor_metric_alert.servicebus_connections_closed[*].id, [])
    size                    = try(azurerm_monitor_metric_alert.servicebus_size[*].id, [])
    active_messages         = try(azurerm_monitor_metric_alert.servicebus_active_messages[*].id, [])
    dead_letter_messages    = try(azurerm_monitor_metric_alert.servicebus_dead_letter_messages[*].id, [])
    scheduled_messages      = try(azurerm_monitor_metric_alert.servicebus_scheduled_messages[*].id, [])
  }
}

output "alert_names" {
  description = "Map of alert names keyed by alert type"
  value = {
    incoming_requests       = try(azurerm_monitor_metric_alert.servicebus_incoming_requests[*].name, [])
    successful_requests_low = try(azurerm_monitor_metric_alert.servicebus_successful_requests_low[*].name, [])
    server_errors           = try(azurerm_monitor_metric_alert.servicebus_server_errors[*].name, [])
    user_errors             = try(azurerm_monitor_metric_alert.servicebus_user_errors[*].name, [])
    throttled_requests      = try(azurerm_monitor_metric_alert.servicebus_throttled_requests[*].name, [])
    incoming_messages       = try(azurerm_monitor_metric_alert.servicebus_incoming_messages[*].name, [])
    outgoing_messages       = try(azurerm_monitor_metric_alert.servicebus_outgoing_messages[*].name, [])
    active_connections      = try(azurerm_monitor_metric_alert.servicebus_active_connections[*].name, [])
    connections_opened      = try(azurerm_monitor_metric_alert.servicebus_connections_opened[*].name, [])
    connections_closed      = try(azurerm_monitor_metric_alert.servicebus_connections_closed[*].name, [])
    size                    = try(azurerm_monitor_metric_alert.servicebus_size[*].name, [])
    active_messages         = try(azurerm_monitor_metric_alert.servicebus_active_messages[*].name, [])
    dead_letter_messages    = try(azurerm_monitor_metric_alert.servicebus_dead_letter_messages[*].name, [])
    scheduled_messages      = try(azurerm_monitor_metric_alert.servicebus_scheduled_messages[*].name, [])
  }
}

output "monitored_resources" {
  description = "List of Service Bus namespace names being monitored"
  value       = var.servicebus_namespace_names
}

output "action_group_id" {
  description = "The ID of the action group associated with the alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub     = try(azurerm_monitor_diagnostic_setting.servicebus_to_eventhub[*].id, [])
    loganalytics = try(azurerm_monitor_diagnostic_setting.servicebus_to_loganalytics[*].id, [])
  }
}

output "alert_summary" {
  description = "Summary of configured alerts and diagnostic settings"
  value = {
    total_alerts              = 14
    total_monitored_resources = length(var.servicebus_namespace_names)
    diagnostic_settings = {
      enabled = var.enable_diagnostic_settings
    }
    alert_categories = {
      request_metrics = [
        "incoming_requests",
        "successful_requests_low",
        "server_errors",
        "user_errors",
        "throttled_requests"
      ]
      message_metrics = [
        "incoming_messages",
        "outgoing_messages",
        "active_messages",
        "dead_letter_messages",
        "scheduled_messages"
      ]
      connection_metrics = [
        "active_connections",
        "connections_opened",
        "connections_closed"
      ]
      resource_metrics = [
        "size"
      ]
    }
  }
}
