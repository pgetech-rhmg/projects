# Output the IDs of all created metric alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    length(azurerm_monitor_metric_alert.eventhub_incoming_requests) > 0 ? {
      "incoming_requests" = azurerm_monitor_metric_alert.eventhub_incoming_requests[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_successful_requests_low) > 0 ? {
      "successful_requests_low" = azurerm_monitor_metric_alert.eventhub_successful_requests_low[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_server_errors) > 0 ? {
      "server_errors" = azurerm_monitor_metric_alert.eventhub_server_errors[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_user_errors) > 0 ? {
      "user_errors" = azurerm_monitor_metric_alert.eventhub_user_errors[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_throttled_requests) > 0 ? {
      "throttled_requests" = azurerm_monitor_metric_alert.eventhub_throttled_requests[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_incoming_messages) > 0 ? {
      "incoming_messages" = azurerm_monitor_metric_alert.eventhub_incoming_messages[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_outgoing_messages) > 0 ? {
      "outgoing_messages" = azurerm_monitor_metric_alert.eventhub_outgoing_messages[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_incoming_bytes) > 0 ? {
      "incoming_bytes" = azurerm_monitor_metric_alert.eventhub_incoming_bytes[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_outgoing_bytes) > 0 ? {
      "outgoing_bytes" = azurerm_monitor_metric_alert.eventhub_outgoing_bytes[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_active_connections) > 0 ? {
      "active_connections" = azurerm_monitor_metric_alert.eventhub_active_connections[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_connections_opened) > 0 ? {
      "connections_opened" = azurerm_monitor_metric_alert.eventhub_connections_opened[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_connections_closed) > 0 ? {
      "connections_closed" = azurerm_monitor_metric_alert.eventhub_connections_closed[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_quota_exceeded_errors) > 0 ? {
      "quota_exceeded_errors" = azurerm_monitor_metric_alert.eventhub_quota_exceeded_errors[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_size) > 0 ? {
      "size" = azurerm_monitor_metric_alert.eventhub_size[0].id
    } : {}
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    length(azurerm_monitor_metric_alert.eventhub_incoming_requests) > 0 ? {
      "incoming_requests" = azurerm_monitor_metric_alert.eventhub_incoming_requests[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_successful_requests_low) > 0 ? {
      "successful_requests_low" = azurerm_monitor_metric_alert.eventhub_successful_requests_low[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_server_errors) > 0 ? {
      "server_errors" = azurerm_monitor_metric_alert.eventhub_server_errors[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_user_errors) > 0 ? {
      "user_errors" = azurerm_monitor_metric_alert.eventhub_user_errors[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_throttled_requests) > 0 ? {
      "throttled_requests" = azurerm_monitor_metric_alert.eventhub_throttled_requests[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_incoming_messages) > 0 ? {
      "incoming_messages" = azurerm_monitor_metric_alert.eventhub_incoming_messages[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_outgoing_messages) > 0 ? {
      "outgoing_messages" = azurerm_monitor_metric_alert.eventhub_outgoing_messages[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_incoming_bytes) > 0 ? {
      "incoming_bytes" = azurerm_monitor_metric_alert.eventhub_incoming_bytes[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_outgoing_bytes) > 0 ? {
      "outgoing_bytes" = azurerm_monitor_metric_alert.eventhub_outgoing_bytes[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_active_connections) > 0 ? {
      "active_connections" = azurerm_monitor_metric_alert.eventhub_active_connections[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_connections_opened) > 0 ? {
      "connections_opened" = azurerm_monitor_metric_alert.eventhub_connections_opened[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_connections_closed) > 0 ? {
      "connections_closed" = azurerm_monitor_metric_alert.eventhub_connections_closed[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_quota_exceeded_errors) > 0 ? {
      "quota_exceeded_errors" = azurerm_monitor_metric_alert.eventhub_quota_exceeded_errors[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventhub_size) > 0 ? {
      "size" = azurerm_monitor_metric_alert.eventhub_size[0].name
    } : {}
  )
}

# Output diagnostic settings information
output "diagnostic_settings" {
  description = "Map of diagnostic settings resource IDs"
  value = {
    eventhub_ids         = { for k, v in azurerm_monitor_diagnostic_setting.eventhub_to_eventhub : k => v.id }
    loganalytics_ids     = { for k, v in azurerm_monitor_diagnostic_setting.eventhub_to_loganalytics : k => v.id }
    eventhub_enabled     = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled = local.diagnostic_settings_loganalytics_enabled
  }
}

# Output the monitored Event Hub namespaces
output "monitored_eventhub_namespaces" {
  description = "List of Event Hub namespace names being monitored"
  value       = var.eventhub_namespace_names
}

# Output the monitored Event Hubs
output "monitored_eventhubs" {
  description = "List of individual Event Hub names being monitored"
  value       = var.eventhub_names
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}
