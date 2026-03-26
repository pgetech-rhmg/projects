# Output values from the Virtual Network monitoring module examples

# =======================================================================================
# Production Environment Outputs
# =======================================================================================

output "production_if_under_ddos_attack_alert_ids" {
  description = "Map of VNet names to their DDoS attack alert IDs (Production)"
  value       = module.vnet_monitoring_production.if_under_ddos_attack_alert_ids
}

output "production_diagnostic_setting_eventhub_ids" {
  description = "Map of VNet names to their Event Hub diagnostic setting IDs (Production)"
  value       = module.vnet_monitoring_production.diagnostic_setting_eventhub_ids
}

output "production_diagnostic_setting_loganalytics_ids" {
  description = "Map of VNet names to their Log Analytics diagnostic setting IDs (Production)"
  value       = module.vnet_monitoring_production.diagnostic_setting_loganalytics_ids
}

output "production_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Production)"
  value       = module.vnet_monitoring_production.monitoring_configuration
}

# =======================================================================================
# Development Environment Outputs
# =======================================================================================

output "development_if_under_ddos_attack_alert_ids" {
  description = "Map of VNet names to their DDoS attack alert IDs (Development)"
  value       = module.vnet_monitoring_development.if_under_ddos_attack_alert_ids
}

output "development_diagnostic_setting_loganalytics_ids" {
  description = "Map of VNet names to their Log Analytics diagnostic setting IDs (Development)"
  value       = module.vnet_monitoring_development.diagnostic_setting_loganalytics_ids
}

output "development_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Development)"
  value       = module.vnet_monitoring_development.monitoring_configuration
}

# =======================================================================================
# Basic/Test Environment Outputs
# =======================================================================================

output "basic_if_under_ddos_attack_alert_ids" {
  description = "Map of VNet names to their DDoS attack alert IDs (Basic/Test)"
  value       = module.vnet_monitoring_basic.if_under_ddos_attack_alert_ids
}

output "basic_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Basic/Test)"
  value       = module.vnet_monitoring_basic.monitoring_configuration
}

# =======================================================================================
# Cross-Environment Comparison
# =======================================================================================

output "all_environments_summary" {
  description = "Summary of monitoring configurations across all environments"
  value = {
    production = {
      vnets_count         = length(module.vnet_monitoring_production.monitored_vnets)
      vnets               = keys(module.vnet_monitoring_production.monitored_vnets)
      alerts_count        = 1
      diagnostics_enabled = true
    }
    development = {
      vnets_count         = length(module.vnet_monitoring_development.monitored_vnets)
      vnets               = keys(module.vnet_monitoring_development.monitored_vnets)
      alerts_count        = 1
      diagnostics_enabled = true
    }
    basic = {
      vnets_count         = length(module.vnet_monitoring_basic.monitored_vnets)
      vnets               = keys(module.vnet_monitoring_basic.monitored_vnets)
      alerts_count        = 1
      diagnostics_enabled = false
    }
  }
}
