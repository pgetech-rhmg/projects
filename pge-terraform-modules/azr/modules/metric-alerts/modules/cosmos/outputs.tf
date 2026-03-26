# Output the IDs of all created metric alerts
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.cosmos_availability : "availability_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_server_side_latency : "server_side_latency_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_ru_consumption : "ru_consumption_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_normalized_ru_consumption : "normalized_ru_consumption_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_total_requests : "total_requests_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_metadata_requests : "metadata_requests_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_data_usage : "data_usage_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_index_usage : "index_usage_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.cosmos_provisioned_throughput : "provisioned_throughput_${k}" => v.id }
  )
}

# Output the names of all created metric alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.cosmos_availability : "availability_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_server_side_latency : "server_side_latency_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_ru_consumption : "ru_consumption_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_normalized_ru_consumption : "normalized_ru_consumption_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_total_requests : "total_requests_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_metadata_requests : "metadata_requests_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_data_usage : "data_usage_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_index_usage : "index_usage_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.cosmos_provisioned_throughput : "provisioned_throughput_${k}" => v.name }
  )
}

# Output diagnostic settings information
output "diagnostic_settings" {
  description = "Map of diagnostic settings resource IDs"
  value = {
    eventhub_ids         = { for k, v in azurerm_monitor_diagnostic_setting.cosmos_to_eventhub : k => v.id }
    loganalytics_ids     = { for k, v in azurerm_monitor_diagnostic_setting.cosmos_to_loganalytics : k => v.id }
    eventhub_enabled     = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled = local.diagnostic_settings_loganalytics_enabled
  }
}

# Output the monitored Cosmos DB accounts
output "monitored_cosmos_accounts" {
  description = "List of Cosmos DB account names being monitored"
  value       = var.cosmos_account_names
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}
