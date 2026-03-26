# Outputs from the Compute Gallery monitoring module examples

# Production deployment outputs
output "production_alert_ids" {
  description = "Map of alert IDs from production deployment"
  value       = module.compute_gallery_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Map of alert names from production deployment"
  value       = module.compute_gallery_alerts_production.alert_names
}

output "production_monitored_subscriptions" {
  description = "List of subscription IDs being monitored in production"
  value       = module.compute_gallery_alerts_production.monitored_subscriptions
}

# Development deployment outputs
output "dev_alert_ids" {
  description = "Map of alert IDs from development deployment"
  value       = module.compute_gallery_alerts_dev.alert_ids
}

output "dev_monitored_subscriptions" {
  description = "List of subscription IDs being monitored in development"
  value       = module.compute_gallery_alerts_dev.monitored_subscriptions
}

# Basic deployment outputs
output "basic_alert_ids" {
  description = "Map of alert IDs from basic deployment"
  value       = module.compute_gallery_alerts_basic.alert_ids
}

output "basic_monitored_subscriptions" {
  description = "List of subscription IDs being monitored in basic deployment"
  value       = module.compute_gallery_alerts_basic.monitored_subscriptions
}
