# Output the IDs of all created metric alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_published_messages) > 0 ? {
      "mqtt_published_messages" = azurerm_monitor_metric_alert.eventgrid_mqtt_published_messages[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_failed_published) > 0 ? {
      "mqtt_failed_published" = azurerm_monitor_metric_alert.eventgrid_mqtt_failed_published[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_connections) > 0 ? {
      "mqtt_connections" = azurerm_monitor_metric_alert.eventgrid_mqtt_connections[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_http_published_events) > 0 ? {
      "http_published_events" = azurerm_monitor_metric_alert.eventgrid_http_published_events[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_http_failed_published) > 0 ? {
      "http_failed_published" = azurerm_monitor_metric_alert.eventgrid_http_failed_published[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_delivery_attempts_failed) > 0 ? {
      "delivery_attempts_failed" = azurerm_monitor_metric_alert.eventgrid_delivery_attempts_failed[0].id
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_delivery_attempts_succeeded) > 0 ? {
      "delivery_attempts_succeeded" = azurerm_monitor_metric_alert.eventgrid_delivery_attempts_succeeded[0].id
    } : {}
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_published_messages) > 0 ? {
      "mqtt_published_messages" = azurerm_monitor_metric_alert.eventgrid_mqtt_published_messages[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_failed_published) > 0 ? {
      "mqtt_failed_published" = azurerm_monitor_metric_alert.eventgrid_mqtt_failed_published[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_mqtt_connections) > 0 ? {
      "mqtt_connections" = azurerm_monitor_metric_alert.eventgrid_mqtt_connections[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_http_published_events) > 0 ? {
      "http_published_events" = azurerm_monitor_metric_alert.eventgrid_http_published_events[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_http_failed_published) > 0 ? {
      "http_failed_published" = azurerm_monitor_metric_alert.eventgrid_http_failed_published[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_delivery_attempts_failed) > 0 ? {
      "delivery_attempts_failed" = azurerm_monitor_metric_alert.eventgrid_delivery_attempts_failed[0].name
    } : {},
    length(azurerm_monitor_metric_alert.eventgrid_delivery_attempts_succeeded) > 0 ? {
      "delivery_attempts_succeeded" = azurerm_monitor_metric_alert.eventgrid_delivery_attempts_succeeded[0].name
    } : {}
  )
}

# Output diagnostic settings information
output "diagnostic_settings" {
  description = "Map of diagnostic settings resource IDs"
  value = {
    eventhub_ids         = { for k, v in azurerm_monitor_diagnostic_setting.eventgrid_namespace_to_eventhub : k => v.id }
    loganalytics_ids     = { for k, v in azurerm_monitor_diagnostic_setting.eventgrid_namespace_to_loganalytics : k => v.id }
    eventhub_enabled     = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled = local.diagnostic_settings_loganalytics_enabled
  }
}

# Output the monitored Event Grid namespaces
output "monitored_eventgrid_namespaces" {
  description = "List of Event Grid namespace names being monitored"
  value       = var.eventgrid_namespace_names
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}
