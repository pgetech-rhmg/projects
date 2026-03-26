# Azure Private DNS Zones Monitoring - Example Outputs

# =======================================================================================
# Production Deployment Outputs
# =======================================================================================

output "production_alert_ids" {
  description = "List of alert resource IDs for production Private DNS zones"
  value       = module.private_dns_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "List of alert names for production Private DNS zones"
  value       = module.private_dns_alerts_production.alert_names
}

output "production_monitored_zones" {
  description = "List of Private DNS zones being monitored in production"
  value       = module.private_dns_alerts_production.monitored_dns_zones
}

output "production_alert_summary" {
  description = "Summary of alerts configured for production Private DNS zones"
  value       = module.private_dns_alerts_production.alert_summary
}

# =======================================================================================
# Development Deployment Outputs
# =======================================================================================

output "development_alert_ids" {
  description = "List of alert resource IDs for development Private DNS zones"
  value       = module.private_dns_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "List of alert names for development Private DNS zones"
  value       = module.private_dns_alerts_development.alert_names
}

output "development_monitored_zones" {
  description = "List of Private DNS zones being monitored in development"
  value       = module.private_dns_alerts_development.monitored_dns_zones
}

output "development_alert_summary" {
  description = "Summary of alerts configured for development Private DNS zones"
  value       = module.private_dns_alerts_development.alert_summary
}

# =======================================================================================
# Basic Deployment Outputs
# =======================================================================================

output "basic_alert_ids" {
  description = "List of alert resource IDs for basic Private DNS deployment"
  value       = module.private_dns_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "List of alert names for basic Private DNS deployment"
  value       = module.private_dns_alerts_basic.alert_names
}

output "basic_monitored_zones" {
  description = "List of Private DNS zones being monitored in basic deployment"
  value       = module.private_dns_alerts_basic.monitored_dns_zones
}

output "basic_alert_summary" {
  description = "Summary of alerts configured for basic Private DNS deployment"
  value       = module.private_dns_alerts_basic.alert_summary
}
