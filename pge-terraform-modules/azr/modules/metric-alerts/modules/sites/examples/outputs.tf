# =======================================================================================
# Production Environment Outputs
# =======================================================================================
output "production_alert_ids" {
  description = "Map of production alert resource IDs"
  value       = module.sites_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Map of production alert names"
  value       = module.sites_alerts_production.alert_names
}

output "production_monitored_resources" {
  description = "App Service sites monitored in production"
  value       = module.sites_alerts_production.monitored_resources
}

output "production_action_group_id" {
  description = "Production action group ID"
  value       = module.sites_alerts_production.action_group_id
}

output "production_diagnostic_settings" {
  description = "Production diagnostic settings IDs"
  value       = module.sites_alerts_production.diagnostic_settings
}

output "production_alert_summary" {
  description = "Production alert configuration summary"
  value       = module.sites_alerts_production.alert_summary
}

# =======================================================================================
# Development Environment Outputs
# =======================================================================================
output "development_alert_ids" {
  description = "Map of development alert resource IDs"
  value       = module.sites_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Map of development alert names"
  value       = module.sites_alerts_development.alert_names
}

output "development_monitored_resources" {
  description = "App Service sites monitored in development"
  value       = module.sites_alerts_development.monitored_resources
}

output "development_action_group_id" {
  description = "Development action group ID"
  value       = module.sites_alerts_development.action_group_id
}

output "development_diagnostic_settings" {
  description = "Development diagnostic settings IDs"
  value       = module.sites_alerts_development.diagnostic_settings
}

output "development_alert_summary" {
  description = "Development alert configuration summary"
  value       = module.sites_alerts_development.alert_summary
}

# =======================================================================================
# Basic/Test Environment Outputs
# =======================================================================================
output "basic_alert_ids" {
  description = "Map of basic alert resource IDs"
  value       = module.sites_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "Map of basic alert names"
  value       = module.sites_alerts_basic.alert_names
}

output "basic_monitored_resources" {
  description = "App Service sites monitored in basic configuration"
  value       = module.sites_alerts_basic.monitored_resources
}

output "basic_action_group_id" {
  description = "Basic action group ID"
  value       = module.sites_alerts_basic.action_group_id
}

output "basic_diagnostic_settings" {
  description = "Basic diagnostic settings IDs"
  value       = module.sites_alerts_basic.diagnostic_settings
}

output "basic_alert_summary" {
  description = "Basic alert configuration summary"
  value       = module.sites_alerts_basic.alert_summary
}
