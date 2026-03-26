# Output the IDs of all created metric alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.front_door_high_response_time : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.front_door_backend_health : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.front_door_high_request_count : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.front_door_high_error_rate : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.front_door_low_availability : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.front_door_waf_blocked_requests : k => v.id }
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.front_door_high_response_time : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.front_door_backend_health : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.front_door_high_request_count : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.front_door_high_error_rate : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.front_door_low_availability : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.front_door_waf_blocked_requests : k => v.name }
  )
}

# Output diagnostic settings information
output "diagnostic_settings" {
  description = "Map of diagnostic settings resource IDs"
  value = {
    eventhub_ids         = { for k, v in azurerm_monitor_diagnostic_setting.frontdoor_to_eventhub : k => v.id }
    loganalytics_ids     = { for k, v in azurerm_monitor_diagnostic_setting.frontdoor_to_loganalytics : k => v.id }
    eventhub_enabled     = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled = local.diagnostic_settings_loganalytics_enabled
  }
}

# Output the monitored Front Door names
output "monitored_frontdoors" {
  description = "List of Front Door names being monitored"
  value       = var.front_door_names
}

# Output the Front Door type being monitored
output "front_door_type" {
  description = "Type of Front Door being monitored (classic or standard)"
  value       = var.front_door_type
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}
