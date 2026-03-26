# Virtual Machine Monitoring Outputs
# These outputs provide visibility into the monitoring configuration

# Metric Alert Outputs - CPU
output "vm_cpu_percentage_alert_ids" {
  description = "Map of VM names to their CPU percentage warning alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_cpu_percentage : k => v.id
  }
}

output "vm_cpu_percentage_critical_alert_ids" {
  description = "Map of VM names to their CPU percentage critical alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_cpu_percentage_critical : k => v.id
  }
}

# Metric Alert Outputs - Memory
output "vm_memory_percentage_alert_ids" {
  description = "Map of VM names to their memory percentage warning alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_memory_percentage : k => v.id
  }
}

output "vm_memory_percentage_critical_alert_ids" {
  description = "Map of VM names to their memory percentage critical alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_memory_percentage_critical : k => v.id
  }
}

# Metric Alert Outputs - Disk I/O
output "vm_disk_read_ops_alert_ids" {
  description = "Map of VM names to their disk read operations alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_disk_read_ops : k => v.id
  }
}

output "vm_disk_write_ops_alert_ids" {
  description = "Map of VM names to their disk write operations alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_disk_write_ops : k => v.id
  }
}

output "vm_disk_queue_depth_alert_ids" {
  description = "Map of VM names to their disk queue depth alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_disk_queue_depth : k => v.id
  }
}

# Metric Alert Outputs - Network
output "vm_network_in_alert_ids" {
  description = "Map of VM names to their network in alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_network_in : k => v.id
  }
}

output "vm_network_out_alert_ids" {
  description = "Map of VM names to their network out alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_network_out : k => v.id
  }
}

# Metric Alert Outputs - Availability
output "vm_heartbeat_alert_ids" {
  description = "Map of VM names to their heartbeat/availability alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_heartbeat : k => v.id
  }
}

# Metric Alert Outputs - Data Disk
output "vm_data_disk_read_bytes_alert_ids" {
  description = "Map of VM names to their data disk read bytes alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_data_disk_read_bytes : k => v.id
  }
}

output "vm_data_disk_write_bytes_alert_ids" {
  description = "Map of VM names to their data disk write bytes alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_data_disk_write_bytes : k => v.id
  }
}

# Metric Alert Outputs - Premium Disk Cache
output "vm_premium_data_disk_cache_miss_alert_ids" {
  description = "Map of VM names to their premium data disk cache miss alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_premium_data_disk_cache_miss : k => v.id
  }
}

output "vm_premium_os_disk_cache_miss_alert_ids" {
  description = "Map of VM names to their premium OS disk cache miss alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.vm_premium_os_disk_cache_miss : k => v.id
  }
}

# Diagnostic Settings Outputs
output "diagnostic_setting_eventhub_ids" {
  description = "Map of VM names to their Event Hub diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.vm_to_eventhub : k => v.id
  }
}

output "diagnostic_setting_loganalytics_ids" {
  description = "Map of VM names to their Log Analytics diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.vm_to_loganalytics : k => v.id
  }
}

# Monitored Resource Outputs
output "monitored_virtual_machines" {
  description = "Map of VM names to their resource IDs"
  value = {
    for k, v in data.azurerm_virtual_machine.virtual_machines : k => v.id
  }
}

# Action Group Output
output "action_group_id" {
  description = "ID of the action group used for alert notifications"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Configuration Summary
output "monitoring_configuration" {
  description = "Summary of the monitoring configuration for Virtual Machines"
  value = {
    monitored_vms_count         = length(var.virtual_machine_names)
    monitored_vms               = var.virtual_machine_names
    metric_alerts_count         = 13
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_resource_group = var.action_group_resource_group_name
    action_group_name           = var.action_group
    resource_group              = var.resource_group_name

    alert_severities = {
      cpu_percentage_critical      = 0
      memory_percentage_critical   = 0
      heartbeat                    = 1
      cpu_percentage               = 2
      memory_percentage            = 2
      disk_read_ops                = 2
      disk_write_ops               = 2
      disk_queue_depth             = 2
      network_in                   = 2
      network_out                  = 2
      data_disk_read_bytes         = 3
      data_disk_write_bytes        = 3
      premium_data_disk_cache_miss = 3
      premium_os_disk_cache_miss   = 3
    }

    thresholds = {
      cpu_percentage                  = var.cpu_percentage_threshold
      cpu_percentage_critical         = var.cpu_percentage_critical_threshold
      memory_percentage               = var.memory_percentage_threshold
      memory_percentage_critical      = var.memory_percentage_critical_threshold
      disk_iops                       = var.disk_iops_threshold
      disk_queue_depth                = var.disk_queue_depth_threshold
      network_in_bytes                = var.network_in_threshold
      network_out_bytes               = var.network_out_threshold
      vm_heartbeat_minutes            = var.vm_heartbeat_threshold
      data_disk_read_bytes            = var.data_disk_read_bytes_threshold
      data_disk_write_bytes           = var.data_disk_write_bytes_threshold
      premium_disk_cache_miss_percent = var.premium_disk_cache_miss_threshold
    }
  }
}
