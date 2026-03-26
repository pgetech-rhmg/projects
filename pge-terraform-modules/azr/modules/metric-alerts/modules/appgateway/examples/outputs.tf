# Outputs for Complete Example

# Production environment outputs
output "production_alert_ids" {
  description = "Alert IDs for production environment"
  value       = module.appgateway_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Alert names for production environment"
  value       = module.appgateway_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic setting IDs for production (both Log Analytics and Event Hub)"
  value       = module.appgateway_alerts_production.diagnostic_setting_ids
}

output "production_monitored_gateways" {
  description = "List of monitored Application Gateway names in production"
  value       = module.appgateway_alerts_production.monitored_application_gateways
}

output "production_application_gateway_ids" {
  description = "Application Gateway resource IDs in production"
  value       = module.appgateway_alerts_production.application_gateway_ids
}

# Development environment outputs
output "dev_alert_ids" {
  description = "Alert IDs for development environment"
  value       = module.appgateway_alerts_dev.alert_ids
}

output "dev_diagnostic_settings" {
  description = "Diagnostic setting IDs for development (Log Analytics only)"
  value       = module.appgateway_alerts_dev.diagnostic_setting_ids
}

# Basic/Test environment outputs
output "basic_alert_ids" {
  description = "Alert IDs for test environment (no diagnostic settings)"
  value       = module.appgateway_alerts_basic.alert_ids
}

output "basic_monitored_gateways" {
  description = "List of monitored Application Gateway names in test"
  value       = module.appgateway_alerts_basic.monitored_application_gateways
}
