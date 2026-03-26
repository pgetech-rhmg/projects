# Output values from the Traffic Manager monitoring module examples

# =======================================================================================
# Production Environment Outputs
# =======================================================================================

output "production_endpoint_health_alert_ids" {
  description = "Map of Traffic Manager profile names to their endpoint health alert IDs (Production)"
  value       = module.trafficmanager_monitoring_production.endpoint_health_alert_ids
}

output "production_probe_agent_endpoint_state_alert_ids" {
  description = "Map of Traffic Manager profile names to their probe agent endpoint state alert IDs (Production)"
  value       = module.trafficmanager_monitoring_production.probe_agent_endpoint_state_alert_ids
}

output "production_traffic_manager_creation_alert_id" {
  description = "ID of the Traffic Manager profile creation alert (Production)"
  value       = module.trafficmanager_monitoring_production.traffic_manager_creation_alert_id
}

output "production_traffic_manager_deletion_alert_id" {
  description = "ID of the Traffic Manager profile deletion alert (Production)"
  value       = module.trafficmanager_monitoring_production.traffic_manager_deletion_alert_id
}

output "production_diagnostic_setting_eventhub_ids" {
  description = "Map of Traffic Manager profile names to their Event Hub diagnostic setting IDs (Production)"
  value       = module.trafficmanager_monitoring_production.diagnostic_setting_eventhub_ids
}

output "production_diagnostic_setting_loganalytics_ids" {
  description = "Map of Traffic Manager profile names to their Log Analytics diagnostic setting IDs (Production)"
  value       = module.trafficmanager_monitoring_production.diagnostic_setting_loganalytics_ids
}

output "production_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Production)"
  value       = module.trafficmanager_monitoring_production.monitoring_configuration
}

# =======================================================================================
# Development Environment Outputs
# =======================================================================================

output "development_endpoint_health_alert_ids" {
  description = "Map of Traffic Manager profile names to their endpoint health alert IDs (Development)"
  value       = module.trafficmanager_monitoring_development.endpoint_health_alert_ids
}

output "development_probe_agent_endpoint_state_alert_ids" {
  description = "Map of Traffic Manager profile names to their probe agent endpoint state alert IDs (Development)"
  value       = module.trafficmanager_monitoring_development.probe_agent_endpoint_state_alert_ids
}

output "development_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Development)"
  value       = module.trafficmanager_monitoring_development.monitoring_configuration
}

# =======================================================================================
# Basic/Test Environment Outputs
# =======================================================================================

output "basic_endpoint_health_alert_ids" {
  description = "Map of Traffic Manager profile names to their endpoint health alert IDs (Basic/Test)"
  value       = module.trafficmanager_monitoring_basic.endpoint_health_alert_ids
}

output "basic_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Basic/Test)"
  value       = module.trafficmanager_monitoring_basic.monitoring_configuration
}

# =======================================================================================
# Cross-Environment Comparison
# =======================================================================================

output "all_environments_summary" {
  description = "Summary of monitoring configurations across all environments"
  value = {
    production = {
      profiles_count = length(module.trafficmanager_monitoring_production.monitored_traffic_manager_profiles)
      profiles       = keys(module.trafficmanager_monitoring_production.monitored_traffic_manager_profiles)
      alerts_count   = 8 # 2 metric + 4 activity + 2 scheduled query
    }
    development = {
      profiles_count = length(module.trafficmanager_monitoring_development.monitored_traffic_manager_profiles)
      profiles       = keys(module.trafficmanager_monitoring_development.monitored_traffic_manager_profiles)
      alerts_count   = 3 # 2 metric + 1 activity (deletion)
    }
    basic = {
      profiles_count = length(module.trafficmanager_monitoring_basic.monitored_traffic_manager_profiles)
      profiles       = keys(module.trafficmanager_monitoring_basic.monitored_traffic_manager_profiles)
      alerts_count   = 2 # 1 metric (endpoint health) + 1 activity (deletion)
    }
  }
}
