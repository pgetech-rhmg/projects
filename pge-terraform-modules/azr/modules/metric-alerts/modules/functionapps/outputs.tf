# Output the IDs of all created metric alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.function_execution_count : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.function_execution_units : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.average_memory_working_set : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.average_response_time : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.average_response_time_critical : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.http_5xx_errors : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.http_4xx_errors : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.memory_working_set : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.io_read_ops : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.io_write_ops : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.private_bytes : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.gen_0_collections : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.gen_1_collections : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.gen_2_collections : k => v.id },
    { for k, v in azurerm_monitor_metric_alert.total_requests : k => v.id }
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.function_execution_count : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.function_execution_units : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.average_memory_working_set : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.average_response_time : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.average_response_time_critical : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.http_5xx_errors : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.http_4xx_errors : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.memory_working_set : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.io_read_ops : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.io_write_ops : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.private_bytes : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.gen_0_collections : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.gen_1_collections : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.gen_2_collections : k => v.name },
    { for k, v in azurerm_monitor_metric_alert.total_requests : k => v.name }
  )
}

# Output diagnostic settings information
output "diagnostic_settings" {
  description = "Map of diagnostic settings resource IDs"
  value = {
    eventhub_ids         = { for k, v in azurerm_monitor_diagnostic_setting.functionapps_to_eventhub : k => v.id }
    loganalytics_ids     = { for k, v in azurerm_monitor_diagnostic_setting.functionapps_to_loganalytics : k => v.id }
    eventhub_enabled     = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled = local.diagnostic_settings_loganalytics_enabled
  }
}

# Output the monitored Windows Function App names
output "monitored_windows_function_apps" {
  description = "List of Windows Function App names being monitored"
  value       = var.windows_function_app_names
}

# Output the monitored Linux Function App names
output "monitored_linux_function_apps" {
  description = "List of Linux Function App names being monitored"
  value       = var.linux_function_app_names
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}
