# Outputs for Azure Connection Monitor AMBA Alerts Module

output "alert_ids" {
  description = "Map of all metric alert resource IDs"
  value = {
    checks_failed_warning  = { for k, v in azurerm_monitor_metric_alert.checks_failed_warning : k => v.id }
    checks_failed_critical = { for k, v in azurerm_monitor_metric_alert.checks_failed_critical : k => v.id }
    latency_warning        = { for k, v in azurerm_monitor_metric_alert.latency_warning : k => v.id }
    latency_critical       = { for k, v in azurerm_monitor_metric_alert.latency_critical : k => v.id }
    test_result_failed     = { for k, v in azurerm_monitor_metric_alert.test_result_failed : k => v.id }
    test_result_warning    = { for k, v in azurerm_monitor_metric_alert.test_result_warning : k => v.id }
  }
}

output "alert_names" {
  description = "Map of all metric alert names"
  value = {
    checks_failed_warning  = { for k, v in azurerm_monitor_metric_alert.checks_failed_warning : k => v.name }
    checks_failed_critical = { for k, v in azurerm_monitor_metric_alert.checks_failed_critical : k => v.name }
    latency_warning        = { for k, v in azurerm_monitor_metric_alert.latency_warning : k => v.name }
    latency_critical       = { for k, v in azurerm_monitor_metric_alert.latency_critical : k => v.name }
    test_result_failed     = { for k, v in azurerm_monitor_metric_alert.test_result_failed : k => v.name }
    test_result_warning    = { for k, v in azurerm_monitor_metric_alert.test_result_warning : k => v.name }
  }
}

output "monitored_connection_monitors" {
  description = "List of Connection Monitor resource IDs being monitored"
  value       = var.connection_monitor_ids
}

output "action_group_id" {
  description = "The ID of the Action Group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}
