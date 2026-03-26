# Production Outputs
output "production_alert_ids" {
  description = "Alert IDs for production deployment"
  value       = module.firewall_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production deployment"
  value       = module.firewall_alerts_production.alert_names
}

output "production_monitored_firewalls" {
  description = "Monitored firewalls for production deployment"
  value       = module.firewall_alerts_production.monitored_firewalls
}

output "production_action_group_id" {
  description = "Action group ID for production deployment"
  value       = module.firewall_alerts_production.action_group_id
}

# Development Outputs
output "development_alert_ids" {
  description = "Alert IDs for development deployment"
  value       = module.firewall_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "Alert names for development deployment"
  value       = module.firewall_alerts_development.alert_names
}

output "development_monitored_firewalls" {
  description = "Monitored firewalls for development deployment"
  value       = module.firewall_alerts_development.monitored_firewalls
}

output "development_action_group_id" {
  description = "Action group ID for development deployment"
  value       = module.firewall_alerts_development.action_group_id
}

# Basic Outputs
output "basic_alert_ids" {
  description = "Alert IDs for basic deployment"
  value       = module.firewall_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "Alert names for basic deployment"
  value       = module.firewall_alerts_basic.alert_names
}

output "basic_monitored_firewalls" {
  description = "Monitored firewalls for basic deployment"
  value       = module.firewall_alerts_basic.monitored_firewalls
}

output "basic_action_group_id" {
  description = "Action group ID for basic deployment"
  value       = module.firewall_alerts_basic.action_group_id
}
