# Outputs from the Connection Monitor monitoring module examples

# Production deployment outputs
output "production_alert_ids" {
  description = "Map of alert IDs from production deployment"
  value       = module.connection_monitor_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Map of alert names from production deployment"
  value       = module.connection_monitor_alerts_production.alert_names
}

output "production_monitored_connection_monitors" {
  description = "List of Connection Monitor resource IDs being monitored in production"
  value       = module.connection_monitor_alerts_production.monitored_connection_monitors
}

# Development deployment outputs
output "dev_alert_ids" {
  description = "Map of alert IDs from development deployment"
  value       = module.connection_monitor_alerts_dev.alert_ids
}

output "dev_monitored_connection_monitors" {
  description = "List of Connection Monitor resource IDs being monitored in development"
  value       = module.connection_monitor_alerts_dev.monitored_connection_monitors
}

# Basic deployment outputs
output "basic_alert_ids" {
  description = "Map of alert IDs from basic deployment"
  value       = module.connection_monitor_alerts_basic.alert_ids
}

output "basic_monitored_connection_monitors" {
  description = "List of Connection Monitor resource IDs being monitored in basic deployment"
  value       = module.connection_monitor_alerts_basic.monitored_connection_monitors
}
