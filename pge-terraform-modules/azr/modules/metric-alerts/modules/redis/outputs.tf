output "alert_ids" {
  description = "Map of alert resource IDs keyed by alert type"
  value = {
    cpu_usage                = try(azurerm_monitor_metric_alert.redis_cpu_usage[*].id, [])
    memory_usage             = try(azurerm_monitor_metric_alert.redis_memory_usage[*].id, [])
    server_load              = try(azurerm_monitor_metric_alert.redis_server_load[*].id, [])
    connected_clients        = try(azurerm_monitor_metric_alert.redis_connected_clients[*].id, [])
    cache_miss_rate          = try(azurerm_monitor_metric_alert.redis_cache_miss_rate[*].id, [])
    evicted_keys             = try(azurerm_monitor_metric_alert.redis_evicted_keys[*].id, [])
    expired_keys             = try(azurerm_monitor_metric_alert.redis_expired_keys[*].id, [])
    total_keys               = try(azurerm_monitor_metric_alert.redis_total_keys[*].id, [])
    operations_per_second    = try(azurerm_monitor_metric_alert.redis_operations_per_second[*].id, [])
    cache_read_bandwidth     = try(azurerm_monitor_metric_alert.redis_cache_read_bandwidth[*].id, [])
    cache_write_bandwidth    = try(azurerm_monitor_metric_alert.redis_cache_write_bandwidth[*].id, [])
    total_commands_processed = try(azurerm_monitor_metric_alert.redis_total_commands_processed[*].id, [])
  }
}

output "alert_names" {
  description = "Map of alert names keyed by alert type"
  value = {
    cpu_usage                = try(azurerm_monitor_metric_alert.redis_cpu_usage[*].name, [])
    memory_usage             = try(azurerm_monitor_metric_alert.redis_memory_usage[*].name, [])
    server_load              = try(azurerm_monitor_metric_alert.redis_server_load[*].name, [])
    connected_clients        = try(azurerm_monitor_metric_alert.redis_connected_clients[*].name, [])
    cache_miss_rate          = try(azurerm_monitor_metric_alert.redis_cache_miss_rate[*].name, [])
    evicted_keys             = try(azurerm_monitor_metric_alert.redis_evicted_keys[*].name, [])
    expired_keys             = try(azurerm_monitor_metric_alert.redis_expired_keys[*].name, [])
    total_keys               = try(azurerm_monitor_metric_alert.redis_total_keys[*].id, [])
    operations_per_second    = try(azurerm_monitor_metric_alert.redis_operations_per_second[*].name, [])
    cache_read_bandwidth     = try(azurerm_monitor_metric_alert.redis_cache_read_bandwidth[*].name, [])
    cache_write_bandwidth    = try(azurerm_monitor_metric_alert.redis_cache_write_bandwidth[*].name, [])
    total_commands_processed = try(azurerm_monitor_metric_alert.redis_total_commands_processed[*].name, [])
  }
}

output "monitored_resources" {
  description = "List of Redis cache names being monitored"
  value       = var.redis_cache_names
}

output "action_group_id" {
  description = "The ID of the action group associated with the alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub     = try(azurerm_monitor_diagnostic_setting.redis_to_eventhub[*].id, [])
    loganalytics = try(azurerm_monitor_diagnostic_setting.redis_to_loganalytics[*].id, [])
  }
}

output "alert_summary" {
  description = "Summary of configured alerts and diagnostic settings"
  value = {
    total_alerts              = 12
    total_monitored_resources = length(var.redis_cache_names)
    diagnostic_settings = {
      enabled = var.enable_diagnostic_settings
    }
    alert_categories = {
      performance = [
        "cpu_usage",
        "memory_usage",
        "server_load",
        "operations_per_second"
      ]
      connectivity = [
        "connected_clients"
      ]
      cache_health = [
        "cache_miss_rate",
        "evicted_keys",
        "expired_keys",
        "total_keys"
      ]
      bandwidth = [
        "cache_read_bandwidth",
        "cache_write_bandwidth"
      ]
      operations = [
        "total_commands_processed"
      ]
    }
  }
}
