output "alert_ids" {
  description = "Map of alert resource IDs keyed by alert type"
  value = {
    response_time          = try(azurerm_monitor_metric_alert.site_response_time[*].id, [])
    response_time_critical = try(azurerm_monitor_metric_alert.site_response_time_critical[*].id, [])
    http_4xx               = try(azurerm_monitor_metric_alert.site_http_4xx[*].id, [])
    http_5xx               = try(azurerm_monitor_metric_alert.site_http_5xx[*].id, [])
    request_rate           = try(azurerm_monitor_metric_alert.site_request_rate[*].id, [])
    cpu_time               = try(azurerm_monitor_metric_alert.site_cpu_time[*].id, [])
    availability           = try(azurerm_monitor_metric_alert.site_availability[*].id, [])
    io_read_ops            = try(azurerm_monitor_metric_alert.site_io_read_ops[*].id, [])
    io_write_ops           = try(azurerm_monitor_metric_alert.site_io_write_ops[*].id, [])
  }
}

output "alert_names" {
  description = "Map of alert names keyed by alert type"
  value = {
    response_time          = try(azurerm_monitor_metric_alert.site_response_time[*].name, [])
    response_time_critical = try(azurerm_monitor_metric_alert.site_response_time_critical[*].name, [])
    http_4xx               = try(azurerm_monitor_metric_alert.site_http_4xx[*].name, [])
    http_5xx               = try(azurerm_monitor_metric_alert.site_http_5xx[*].name, [])
    request_rate           = try(azurerm_monitor_metric_alert.site_request_rate[*].name, [])
    cpu_time               = try(azurerm_monitor_metric_alert.site_cpu_time[*].name, [])
    availability           = try(azurerm_monitor_metric_alert.site_availability[*].name, [])
    io_read_ops            = try(azurerm_monitor_metric_alert.site_io_read_ops[*].name, [])
    io_write_ops           = try(azurerm_monitor_metric_alert.site_io_write_ops[*].name, [])
  }
}

output "monitored_resources" {
  description = "Map of site names being monitored by OS type"
  value = {
    windows_sites = var.windows_site_names
    linux_sites   = var.linux_site_names
    total_sites   = length(var.windows_site_names) + length(var.linux_site_names)
  }
}

output "action_group_id" {
  description = "The ID of the action group associated with the alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    windows_eventhub     = try(azurerm_monitor_diagnostic_setting.windows_site_to_eventhub[*].id, [])
    windows_loganalytics = try(azurerm_monitor_diagnostic_setting.windows_site_to_loganalytics[*].id, [])
    linux_eventhub       = try(azurerm_monitor_diagnostic_setting.linux_site_to_eventhub[*].id, [])
    linux_loganalytics   = try(azurerm_monitor_diagnostic_setting.linux_site_to_loganalytics[*].id, [])
  }
}

output "alert_summary" {
  description = "Summary of configured alerts and diagnostic settings"
  value = {
    total_alerts              = 9
    total_monitored_resources = length(var.windows_site_names) + length(var.linux_site_names)
    windows_sites_count       = length(var.windows_site_names)
    linux_sites_count         = length(var.linux_site_names)
    diagnostic_settings = {
      enabled = var.enable_diagnostic_settings
    }
    alert_categories = {
      performance = [
        "response_time",
        "response_time_critical",
        "cpu_time"
      ]
      availability = [
        "availability",
        "http_4xx",
        "http_5xx"
      ]
      throughput = [
        "request_rate"
      ]
      io_operations = [
        "io_read_ops",
        "io_write_ops"
      ]
    }
  }
}
