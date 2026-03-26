# Production Outputs
output "production_alert_ids" {
  description = "Alert IDs for production deployment"
  value       = module.eventgrid_namespace_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production deployment"
  value       = module.eventgrid_namespace_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings for production deployment"
  value       = module.eventgrid_namespace_alerts_production.diagnostic_settings
}

output "production_monitored_namespaces" {
  description = "Monitored namespaces for production deployment"
  value       = module.eventgrid_namespace_alerts_production.monitored_eventgrid_namespaces
}

output "production_action_group_id" {
  description = "Action group ID for production deployment"
  value       = module.eventgrid_namespace_alerts_production.action_group_id
}

# Development Outputs
output "development_alert_ids" {
  description = "Alert IDs for development deployment"
  value       = module.eventgrid_namespace_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development deployment"
  value       = module.eventgrid_namespace_alerts_development.alert_names
}

output "development_diagnostic_settings" {
  description = "Diagnostic settings for development deployment"
  value       = module.eventgrid_namespace_alerts_development.diagnostic_settings
}

output "development_monitored_namespaces" {
  description = "Monitored namespaces for development deployment"
  value       = module.eventgrid_namespace_alerts_development.monitored_eventgrid_namespaces
}

output "development_action_group_id" {
  description = "Action group ID for development deployment"
  value       = module.eventgrid_namespace_alerts_development.action_group_id
}

# Basic Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic deployment"
  value       = module.eventgrid_namespace_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "Alert names for basic deployment"
  value       = module.eventgrid_namespace_alerts_basic.alert_names
}

output "basic_diagnostic_settings" {
  description = "Diagnostic settings for basic deployment"
  value       = module.eventgrid_namespace_alerts_basic.diagnostic_settings
}

output "basic_monitored_namespaces" {
  description = "Monitored namespaces for basic deployment"
  value       = module.eventgrid_namespace_alerts_basic.monitored_eventgrid_namespaces
}

output "basic_action_group_id" {
  description = "Action group ID for basic deployment"
  value       = module.eventgrid_namespace_alerts_basic.action_group_id
}
