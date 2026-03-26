# Azure Key Vault Monitoring Module Outputs

# Alert Resource IDs
output "alert_ids" {
  description = "List of all alert resource IDs created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.kv_availability : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_latency : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_hit : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_result_errors : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_saturation_shoebox : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_authentication_failures : alert.id],
    [for alert in azurerm_monitor_metric_alert.kv_throttling : alert.id]
  )
}

# Alert Names
output "alert_names" {
  description = "List of all alert names created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.kv_availability : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_latency : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_hit : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_service_api_result_errors : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_saturation_shoebox : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_authentication_failures : alert.name],
    [for alert in azurerm_monitor_metric_alert.kv_throttling : alert.name]
  )
}

# Monitored Resources
output "monitored_key_vaults" {
  description = "List of Key Vault names being monitored"
  value       = var.key_vault_names
}

output "monitored_resource_group" {
  description = "Resource group name where Key Vaults are located"
  value       = var.resource_group_name
}

# Action Group Information
output "action_group_id" {
  description = "Resource ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Diagnostic Settings Outputs
output "diagnostic_settings" {
  description = "Map of diagnostic settings configurations for Key Vaults"
  value = {
    eventhub_enabled              = local.diagnostic_settings_eventhub_enabled
    loganalytics_enabled          = local.diagnostic_settings_loganalytics_enabled
    eventhub_namespace            = var.eventhub_namespace_name
    eventhub_name                 = var.eventhub_name
    log_analytics_workspace       = var.log_analytics_workspace_name
    eventhub_subscription_id      = local.eventhub_subscription_id
    log_analytics_subscription_id = local.log_analytics_subscription_id
  }
}

# Alert Type Summary
output "alert_summary" {
  description = "Summary of alert types configured"
  value = {
    availability_alerts   = length(azurerm_monitor_metric_alert.kv_availability)
    latency_alerts        = length(azurerm_monitor_metric_alert.kv_service_api_latency)
    api_hit_alerts        = length(azurerm_monitor_metric_alert.kv_service_api_hit)
    api_error_alerts      = length(azurerm_monitor_metric_alert.kv_service_api_result_errors)
    saturation_alerts     = length(azurerm_monitor_metric_alert.kv_saturation_shoebox)
    authentication_alerts = length(azurerm_monitor_metric_alert.kv_authentication_failures)
    throttling_alerts     = length(azurerm_monitor_metric_alert.kv_throttling)
    total_metric_alerts = length(concat(
      [for alert in azurerm_monitor_metric_alert.kv_availability : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_service_api_latency : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_service_api_hit : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_service_api_result_errors : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_saturation_shoebox : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_authentication_failures : alert.id],
      [for alert in azurerm_monitor_metric_alert.kv_throttling : alert.id]
    ))
  }
}
