# Output values from the Virtual Machine monitoring module examples

# =======================================================================================
# Production Environment Outputs
# =======================================================================================

output "production_cpu_percentage_alert_ids" {
  description = "Map of VM names to their CPU percentage warning alert IDs (Production)"
  value       = module.vm_monitoring_production.vm_cpu_percentage_alert_ids
}

output "production_cpu_percentage_critical_alert_ids" {
  description = "Map of VM names to their CPU percentage critical alert IDs (Production)"
  value       = module.vm_monitoring_production.vm_cpu_percentage_critical_alert_ids
}

output "production_memory_percentage_alert_ids" {
  description = "Map of VM names to their memory percentage warning alert IDs (Production)"
  value       = module.vm_monitoring_production.vm_memory_percentage_alert_ids
}

output "production_heartbeat_alert_ids" {
  description = "Map of VM names to their heartbeat/availability alert IDs (Production)"
  value       = module.vm_monitoring_production.vm_heartbeat_alert_ids
}

output "production_diagnostic_setting_eventhub_ids" {
  description = "Map of VM names to their Event Hub diagnostic setting IDs (Production)"
  value       = module.vm_monitoring_production.diagnostic_setting_eventhub_ids
}

output "production_diagnostic_setting_loganalytics_ids" {
  description = "Map of VM names to their Log Analytics diagnostic setting IDs (Production)"
  value       = module.vm_monitoring_production.diagnostic_setting_loganalytics_ids
}

output "production_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Production)"
  value       = module.vm_monitoring_production.monitoring_configuration
}

# =======================================================================================
# Development Environment Outputs
# =======================================================================================

output "development_cpu_percentage_alert_ids" {
  description = "Map of VM names to their CPU percentage warning alert IDs (Development)"
  value       = module.vm_monitoring_development.vm_cpu_percentage_alert_ids
}

output "development_cpu_percentage_critical_alert_ids" {
  description = "Map of VM names to their CPU percentage critical alert IDs (Development)"
  value       = module.vm_monitoring_development.vm_cpu_percentage_critical_alert_ids
}

output "development_heartbeat_alert_ids" {
  description = "Map of VM names to their heartbeat/availability alert IDs (Development)"
  value       = module.vm_monitoring_development.vm_heartbeat_alert_ids
}

output "development_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Development)"
  value       = module.vm_monitoring_development.monitoring_configuration
}

# =======================================================================================
# Basic/Test Environment Outputs
# =======================================================================================

output "basic_cpu_percentage_alert_ids" {
  description = "Map of VM names to their CPU percentage warning alert IDs (Basic/Test)"
  value       = module.vm_monitoring_basic.vm_cpu_percentage_alert_ids
}

output "basic_heartbeat_alert_ids" {
  description = "Map of VM names to their heartbeat/availability alert IDs (Basic/Test)"
  value       = module.vm_monitoring_basic.vm_heartbeat_alert_ids
}

output "basic_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Basic/Test)"
  value       = module.vm_monitoring_basic.monitoring_configuration
}

# =======================================================================================
# Cross-Environment Comparison
# =======================================================================================

output "all_environments_summary" {
  description = "Summary of monitoring configurations across all environments"
  value = {
    production = {
      vms_count           = length(module.vm_monitoring_production.monitored_virtual_machines)
      vms                 = keys(module.vm_monitoring_production.monitored_virtual_machines)
      alerts_count        = 13
      cpu_threshold       = 75
      diagnostics_enabled = true
    }
    development = {
      vms_count           = length(module.vm_monitoring_development.monitored_virtual_machines)
      vms                 = keys(module.vm_monitoring_development.monitored_virtual_machines)
      alerts_count        = 13
      cpu_threshold       = 85
      diagnostics_enabled = true
    }
    basic = {
      vms_count           = length(module.vm_monitoring_basic.monitored_virtual_machines)
      vms                 = keys(module.vm_monitoring_basic.monitored_virtual_machines)
      alerts_count        = 13
      cpu_threshold       = 90
      diagnostics_enabled = false
    }
  }
}
