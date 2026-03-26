# Production Environment Outputs
output "production_alert_ids" {
  description = "Alert IDs for production Cosmos DB accounts"
  value       = module.cosmos_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production Cosmos DB accounts"
  value       = module.cosmos_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings for production Cosmos DB accounts"
  value       = module.cosmos_alerts_production.diagnostic_settings
}

output "production_monitored_accounts" {
  description = "List of monitored Cosmos DB accounts in production"
  value       = module.cosmos_alerts_production.monitored_cosmos_accounts
}

# Development Environment Outputs
output "development_alert_ids" {
  description = "Alert IDs for development Cosmos DB accounts"
  value       = module.cosmos_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development Cosmos DB accounts"
  value       = module.cosmos_alerts_development.alert_names
}

# Basic Environment Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic Cosmos DB monitoring"
  value       = module.cosmos_alerts_basic.alert_ids
}

output "basic_action_group_id" {
  description = "Action group ID used for basic alerts"
  value       = module.cosmos_alerts_basic.action_group_id
}
