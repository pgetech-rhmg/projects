# Production Outputs
output "production_alert_ids" {
  description = "Alert IDs for production deployment"
  value       = module.frontdoor_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production deployment"
  value       = module.frontdoor_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings for production deployment"
  value       = module.frontdoor_alerts_production.diagnostic_settings
}

output "production_monitored_frontdoors" {
  description = "Monitored Front Doors for production deployment"
  value       = module.frontdoor_alerts_production.monitored_frontdoors
}

output "production_front_door_type" {
  description = "Front Door type for production deployment"
  value       = module.frontdoor_alerts_production.front_door_type
}

output "production_action_group_id" {
  description = "Action group ID for production deployment"
  value       = module.frontdoor_alerts_production.action_group_id
}

# Development Outputs
output "development_alert_ids" {
  description = "Alert IDs for development deployment"
  value       = module.frontdoor_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development deployment"
  value       = module.frontdoor_alerts_development.alert_names
}

output "development_diagnostic_settings" {
  description = "Diagnostic settings for development deployment"
  value       = module.frontdoor_alerts_development.diagnostic_settings
}

output "development_monitored_frontdoors" {
  description = "Monitored Front Doors for development deployment"
  value       = module.frontdoor_alerts_development.monitored_frontdoors
}

output "development_front_door_type" {
  description = "Front Door type for development deployment"
  value       = module.frontdoor_alerts_development.front_door_type
}

output "development_action_group_id" {
  description = "Action group ID for development deployment"
  value       = module.frontdoor_alerts_development.action_group_id
}

# Basic Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic deployment"
  value       = module.frontdoor_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "Alert names for basic deployment"
  value       = module.frontdoor_alerts_basic.alert_names
}

output "basic_diagnostic_settings" {
  description = "Diagnostic settings for basic deployment"
  value       = module.frontdoor_alerts_basic.diagnostic_settings
}

output "basic_monitored_frontdoors" {
  description = "Monitored Front Doors for basic deployment"
  value       = module.frontdoor_alerts_basic.monitored_frontdoors
}

output "basic_front_door_type" {
  description = "Front Door type for basic deployment"
  value       = module.frontdoor_alerts_basic.front_door_type
}

output "basic_action_group_id" {
  description = "Action group ID for basic deployment"
  value       = module.frontdoor_alerts_basic.action_group_id
}
