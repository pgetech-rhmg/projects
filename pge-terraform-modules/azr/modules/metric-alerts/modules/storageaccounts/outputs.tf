# Outputs for Storage Account Monitoring Module

# Alert Resource IDs
output "alert_ids" {
  description = "Map of alert resource IDs by alert type"
  value = {
    availability   = { for k, v in azurerm_monitor_metric_alert.storage_availability : k => v.id }
    latency        = { for k, v in azurerm_monitor_metric_alert.storage_latency : k => v.id }
    server_latency = { for k, v in azurerm_monitor_metric_alert.storage_server_latency : k => v.id }
    capacity       = { for k, v in azurerm_monitor_metric_alert.storage_capacity : k => v.id }
    transactions   = { for k, v in azurerm_monitor_metric_alert.storage_transactions : k => v.id }
    errors         = { for k, v in azurerm_monitor_metric_alert.storage_errors : k => v.id }
  }
}

# Alert Names
output "alert_names" {
  description = "Map of alert names by alert type"
  value = {
    availability   = { for k, v in azurerm_monitor_metric_alert.storage_availability : k => v.name }
    latency        = { for k, v in azurerm_monitor_metric_alert.storage_latency : k => v.name }
    server_latency = { for k, v in azurerm_monitor_metric_alert.storage_server_latency : k => v.name }
    capacity       = { for k, v in azurerm_monitor_metric_alert.storage_capacity : k => v.name }
    transactions   = { for k, v in azurerm_monitor_metric_alert.storage_transactions : k => v.name }
    errors         = { for k, v in azurerm_monitor_metric_alert.storage_errors : k => v.name }
  }
}

# Monitored Resources
output "monitored_resources" {
  description = "Map of monitored Storage Account resource IDs"
  value = {
    account_ids   = { for k, v in data.azurerm_storage_account.storage_accounts : k => v.id }
    account_names = var.storage_account_names
    account_count = length(var.storage_account_names)
  }
}

# Action Group
output "action_group_id" {
  description = "The ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Diagnostic Settings
output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub     = { for k, v in azurerm_monitor_diagnostic_setting.storageaccount_to_eventhub : k => v.id }
    loganalytics = { for k, v in azurerm_monitor_diagnostic_setting.storageaccount_to_loganalytics : k => v.id }
  }
}

# Configuration Summary
output "alert_summary" {
  description = "Summary of alert configuration"
  value = {
    total_alerts       = 6
    accounts_monitored = length(var.storage_account_names)
    alert_categories = {
      availability_alerts = 1
      performance_alerts  = 3
      capacity_alerts     = 1
      error_alerts        = 1
    }
    configured_thresholds = {
      availability   = var.storage_availability_threshold
      capacity       = var.storage_capacity_threshold
      transactions   = var.storage_transaction_threshold
      latency        = var.storage_latency_threshold
      server_latency = var.storage_server_latency_threshold
    }
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_name           = var.action_group
  }
}
