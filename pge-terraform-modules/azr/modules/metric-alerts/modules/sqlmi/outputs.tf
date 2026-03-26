# Outputs for SQL Managed Instance Monitoring Module

# Alert Resource IDs
output "alert_ids" {
  description = "Map of alert resource IDs by alert type"
  value = {
    cpu_warning      = [for alert in azurerm_monitor_metric_alert.sqlmi_cpu_warning : alert.id]
    cpu_critical     = [for alert in azurerm_monitor_metric_alert.sqlmi_cpu_critical : alert.id]
    storage_warning  = [for alert in azurerm_monitor_metric_alert.sqlmi_storage_warning : alert.id]
    storage_critical = [for alert in azurerm_monitor_metric_alert.sqlmi_storage_critical : alert.id]
    vcore_warning    = [for alert in azurerm_monitor_metric_alert.sqlmi_vcore_warning : alert.id]
  }
}

# Alert Names
output "alert_names" {
  description = "Map of alert names by alert type"
  value = {
    cpu_warning      = [for alert in azurerm_monitor_metric_alert.sqlmi_cpu_warning : alert.name]
    cpu_critical     = [for alert in azurerm_monitor_metric_alert.sqlmi_cpu_critical : alert.name]
    storage_warning  = [for alert in azurerm_monitor_metric_alert.sqlmi_storage_warning : alert.name]
    storage_critical = [for alert in azurerm_monitor_metric_alert.sqlmi_storage_critical : alert.name]
    vcore_warning    = [for alert in azurerm_monitor_metric_alert.sqlmi_vcore_warning : alert.name]
  }
}

# Monitored Resources
output "monitored_resources" {
  description = "Map of monitored SQL Managed Instance resource IDs"
  value = {
    instance_ids   = [for mi in data.azurerm_mssql_managed_instance.sql_managed_instances : mi.id]
    instance_names = var.sql_mi_names
    instance_count = length(var.sql_mi_names)
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
    eventhub     = [for ds in azurerm_monitor_diagnostic_setting.sqlmi_to_eventhub : ds.id]
    loganalytics = [for ds in azurerm_monitor_diagnostic_setting.sqlmi_to_loganalytics : ds.id]
  }
}

# Configuration Summary
output "alert_summary" {
  description = "Summary of alert configuration"
  value = {
    total_alerts        = 5
    instances_monitored = length(var.sql_mi_names)
    alert_categories = {
      cpu_alerts     = 2
      storage_alerts = 2
      vcore_alerts   = 1
    }
    configured_thresholds = {
      cpu_warning      = var.cpu_warning_threshold
      cpu_critical     = var.cpu_critical_threshold
      storage_warning  = var.storage_warning_threshold
      storage_critical = var.storage_critical_threshold
    }
    evaluation_settings = {
      frequency   = var.evaluation_frequency
      window_size = var.window_size
    }
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_name           = var.action_group
  }
}
