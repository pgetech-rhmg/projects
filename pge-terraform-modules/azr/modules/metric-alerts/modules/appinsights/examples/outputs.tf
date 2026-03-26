# Outputs from the Application Insights monitoring module examples

# Production deployment outputs
output "production_alert_ids" {
  description = "Map of alert IDs from production deployment"
  value       = module.appinsights_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Map of alert names from production deployment"
  value       = module.appinsights_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings IDs from production deployment"
  value       = module.appinsights_alerts_production.diagnostic_setting_ids
}

output "production_monitored_application_insights" {
  description = "Map of Application Insights being monitored in production"
  value       = module.appinsights_alerts_production.monitored_application_insights
}

# Development deployment outputs
output "dev_alert_ids" {
  description = "Map of alert IDs from development deployment"
  value       = module.appinsights_alerts_dev.alert_ids
}

output "dev_monitored_application_insights" {
  description = "Map of Application Insights being monitored in development"
  value       = module.appinsights_alerts_dev.monitored_application_insights
}

# Basic deployment outputs
output "basic_alert_ids" {
  description = "Map of alert IDs from basic deployment"
  value       = module.appinsights_alerts_basic.alert_ids
}

output "basic_monitored_application_insights" {
  description = "Map of Application Insights being monitored in basic deployment"
  value       = module.appinsights_alerts_basic.monitored_application_insights
}
