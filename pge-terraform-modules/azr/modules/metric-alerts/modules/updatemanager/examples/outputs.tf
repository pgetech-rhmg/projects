# Output values from the Update Manager monitoring module examples

# =======================================================================================
# Production Environment Outputs
# =======================================================================================

output "production_update_deployment_failed_alert_id" {
  description = "ID of the update deployment failed alert (Production)"
  value       = module.updatemanager_monitoring_production.update_deployment_failed_alert_id
}

output "production_critical_updates_available_alert_id" {
  description = "ID of the critical updates available alert (Production)"
  value       = module.updatemanager_monitoring_production.critical_updates_available_alert_id
}

output "production_update_installation_failures_alert_id" {
  description = "ID of the update installation failures alert (Production)"
  value       = module.updatemanager_monitoring_production.update_installation_failures_alert_id
}

output "production_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Production)"
  value       = module.updatemanager_monitoring_production.monitoring_configuration
}

# =======================================================================================
# Development Environment Outputs
# =======================================================================================

output "development_update_deployment_failed_alert_id" {
  description = "ID of the update deployment failed alert (Development)"
  value       = module.updatemanager_monitoring_development.update_deployment_failed_alert_id
}

output "development_critical_updates_available_alert_id" {
  description = "ID of the critical updates available alert (Development)"
  value       = module.updatemanager_monitoring_development.critical_updates_available_alert_id
}

output "development_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Development)"
  value       = module.updatemanager_monitoring_development.monitoring_configuration
}

# =======================================================================================
# Basic/Test Environment Outputs
# =======================================================================================

output "basic_update_deployment_failed_alert_id" {
  description = "ID of the update deployment failed alert (Basic/Test)"
  value       = module.updatemanager_monitoring_basic.update_deployment_failed_alert_id
}

output "basic_monitoring_summary" {
  description = "Comprehensive monitoring configuration summary (Basic/Test)"
  value       = module.updatemanager_monitoring_basic.monitoring_configuration
}

# =======================================================================================
# Cross-Environment Comparison
# =======================================================================================

output "all_environments_summary" {
  description = "Summary of monitoring configurations across all environments"
  value = {
    production = {
      monitored_subscriptions = length(module.updatemanager_monitoring_production.monitored_subscription_ids)
      monitored_vms           = length(module.updatemanager_monitoring_production.monitored_vm_resource_ids)
      alerts_count            = 12 # 6 activity log + 6 scheduled query rules
      compliance_threshold    = 95
    }
    development = {
      monitored_subscriptions = length(module.updatemanager_monitoring_development.monitored_subscription_ids)
      monitored_vms           = length(module.updatemanager_monitoring_development.monitored_vm_resource_ids)
      alerts_count            = 8 # Reduced alerts
      compliance_threshold    = 80
    }
    basic = {
      monitored_subscriptions = length(module.updatemanager_monitoring_basic.monitored_subscription_ids)
      monitored_vms           = length(module.updatemanager_monitoring_basic.monitored_vm_resource_ids)
      alerts_count            = 6 # Minimal alerts
      compliance_threshold    = 70
    }
  }
}
