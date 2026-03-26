# Azure Monitor Resources Monitoring - Example Outputs

# =======================================================================================
# Production Deployment Outputs
# =======================================================================================

output "production_alert_ids" {
  description = "List of alert resource IDs for production monitoring resources"
  value       = module.monitor_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "List of alert names for production monitoring resources"
  value       = module.monitor_alerts_production.alert_names
}

output "production_monitored_workspaces" {
  description = "List of Log Analytics workspaces being monitored in production"
  value       = module.monitor_alerts_production.monitored_log_analytics_workspaces
}

output "production_monitored_app_insights" {
  description = "List of Application Insights being monitored in production"
  value       = module.monitor_alerts_production.monitored_application_insights
}

output "production_alert_summary" {
  description = "Summary of alerts configured for production monitoring resources"
  value       = module.monitor_alerts_production.alert_summary
}

output "production_alert_categories" {
  description = "Alert categories enabled for production"
  value       = module.monitor_alerts_production.alert_categories_enabled
}

# =======================================================================================
# Development Deployment Outputs
# =======================================================================================

output "development_alert_ids" {
  description = "List of alert resource IDs for development monitoring resources"
  value       = module.monitor_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "List of alert names for development monitoring resources"
  value       = module.monitor_alerts_development.alert_names
}

output "development_monitored_workspaces" {
  description = "List of Log Analytics workspaces being monitored in development"
  value       = module.monitor_alerts_development.monitored_log_analytics_workspaces
}

output "development_monitored_app_insights" {
  description = "List of Application Insights being monitored in development"
  value       = module.monitor_alerts_development.monitored_application_insights
}

output "development_alert_summary" {
  description = "Summary of alerts configured for development monitoring resources"
  value       = module.monitor_alerts_development.alert_summary
}

# =======================================================================================
# Basic Deployment Outputs
# =======================================================================================

output "basic_alert_ids" {
  description = "List of alert resource IDs for basic monitoring deployment"
  value       = module.monitor_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "List of alert names for basic monitoring deployment"
  value       = module.monitor_alerts_basic.alert_names
}

output "basic_monitored_workspaces" {
  description = "List of Log Analytics workspaces being monitored in basic deployment"
  value       = module.monitor_alerts_basic.monitored_log_analytics_workspaces
}

output "basic_monitored_app_insights" {
  description = "List of Application Insights being monitored in basic deployment"
  value       = module.monitor_alerts_basic.monitored_application_insights
}

output "basic_alert_summary" {
  description = "Summary of alerts configured for basic monitoring deployment"
  value       = module.monitor_alerts_basic.alert_summary
}
