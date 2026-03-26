# Production Environment Outputs
output "production_alert_ids" {
  description = "Alert IDs for production Defender for Cloud monitoring"
  value       = module.defender_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production Defender for Cloud monitoring"
  value       = module.defender_alerts_production.alert_names
}

output "production_monitored_subscriptions" {
  description = "List of monitored subscriptions in production"
  value       = module.defender_alerts_production.monitored_subscriptions
}

output "production_enabled_features" {
  description = "Enabled security monitoring features for production"
  value       = module.defender_alerts_production.enabled_features
}

# Development Environment Outputs
output "development_alert_ids" {
  description = "Alert IDs for development Defender for Cloud monitoring"
  value       = module.defender_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development Defender for Cloud monitoring"
  value       = module.defender_alerts_development.alert_names
}

# Basic Environment Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic Defender for Cloud monitoring"
  value       = module.defender_alerts_basic.alert_ids
}

output "basic_action_group_id" {
  description = "Action group ID used for basic alerts"
  value       = module.defender_alerts_basic.action_group_id
}
