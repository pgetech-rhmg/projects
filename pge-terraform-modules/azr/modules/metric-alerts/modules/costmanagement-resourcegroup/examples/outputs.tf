# Production Environment Outputs
output "production_alert_ids" {
  description = "Alert IDs for production cost management"
  value       = module.cost_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production cost management"
  value       = module.cost_alerts_production.alert_names
}

output "production_monitored_resource_groups" {
  description = "List of monitored resource groups in production"
  value       = module.cost_alerts_production.monitored_resource_groups
}

output "production_budget_thresholds" {
  description = "Budget thresholds configuration for production"
  value       = module.cost_alerts_production.budget_thresholds
}

# Development Environment Outputs
output "development_alert_ids" {
  description = "Alert IDs for development cost management"
  value       = module.cost_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development cost management"
  value       = module.cost_alerts_development.alert_names
}

output "development_subscription_id" {
  description = "Subscription ID for development environment"
  value       = module.cost_alerts_development.subscription_id
}

# Basic Environment Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic cost management"
  value       = module.cost_alerts_basic.alert_ids
}

output "basic_action_group_id" {
  description = "Action group ID used for basic alerts"
  value       = module.cost_alerts_basic.action_group_id
}
