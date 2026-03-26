output "alert_ids" {
  description = "Map of alert resource IDs keyed by alert type"
  value = {
    cpu_percentage    = try(azurerm_monitor_metric_alert.serverfarm_cpu_percentage[*].id, [])
    memory_percentage = try(azurerm_monitor_metric_alert.serverfarm_memory_percentage[*].id, [])
    http_queue_length = try(azurerm_monitor_metric_alert.serverfarm_http_queue_length[*].id, [])
    disk_queue_length = try(azurerm_monitor_metric_alert.serverfarm_disk_queue_length[*].id, [])
  }
}

output "alert_names" {
  description = "Map of alert names keyed by alert type"
  value = {
    cpu_percentage    = try(azurerm_monitor_metric_alert.serverfarm_cpu_percentage[*].name, [])
    memory_percentage = try(azurerm_monitor_metric_alert.serverfarm_memory_percentage[*].name, [])
    http_queue_length = try(azurerm_monitor_metric_alert.serverfarm_http_queue_length[*].name, [])
    disk_queue_length = try(azurerm_monitor_metric_alert.serverfarm_disk_queue_length[*].name, [])
  }
}

output "monitored_resources" {
  description = "List of App Service Plan names being monitored"
  value       = var.serverfarm_names
}

output "action_group_id" {
  description = "The ID of the action group associated with the alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub     = try(azurerm_monitor_diagnostic_setting.serverfarm_to_eventhub[*].id, [])
    loganalytics = try(azurerm_monitor_diagnostic_setting.serverfarm_to_loganalytics[*].id, [])
  }
}

output "alert_summary" {
  description = "Summary of configured alerts and diagnostic settings"
  value = {
    total_alerts              = 4
    total_monitored_resources = length(var.serverfarm_names)
    diagnostic_settings = {
      enabled = var.enable_diagnostic_settings
    }
    alert_categories = {
      performance = [
        "cpu_percentage",
        "memory_percentage"
      ]
      queue_management = [
        "http_queue_length",
        "disk_queue_length"
      ]
    }
  }
}
