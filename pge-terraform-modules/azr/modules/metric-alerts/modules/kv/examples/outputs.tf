# Azure Key Vault Monitoring - Example Outputs

# =======================================================================================
# Production Deployment Outputs
# =======================================================================================

output "production_alert_ids" {
  description = "List of alert resource IDs for production Key Vaults"
  value       = module.keyvault_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "List of alert names for production Key Vaults"
  value       = module.keyvault_alerts_production.alert_names
}

output "production_monitored_vaults" {
  description = "List of Key Vaults being monitored in production"
  value       = module.keyvault_alerts_production.monitored_key_vaults
}

output "production_alert_summary" {
  description = "Summary of alerts configured for production Key Vaults"
  value       = module.keyvault_alerts_production.alert_summary
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings configuration for production Key Vaults"
  value       = module.keyvault_alerts_production.diagnostic_settings
}

# =======================================================================================
# Development Deployment Outputs
# =======================================================================================

output "development_alert_ids" {
  description = "List of alert resource IDs for development Key Vaults"
  value       = module.keyvault_alerts_development.alert_ids
}

output "development_alert_names" {
  description = "List of alert names for development Key Vaults"
  value       = module.keyvault_alerts_development.alert_names
}

output "development_monitored_vaults" {
  description = "List of Key Vaults being monitored in development"
  value       = module.keyvault_alerts_development.monitored_key_vaults
}

output "development_alert_summary" {
  description = "Summary of alerts configured for development Key Vaults"
  value       = module.keyvault_alerts_development.alert_summary
}

# =======================================================================================
# Basic Deployment Outputs
# =======================================================================================

output "basic_alert_ids" {
  description = "List of alert resource IDs for basic Key Vault deployment"
  value       = module.keyvault_alerts_basic.alert_ids
}

output "basic_alert_names" {
  description = "List of alert names for basic Key Vault deployment"
  value       = module.keyvault_alerts_basic.alert_names
}

output "basic_monitored_vaults" {
  description = "List of Key Vaults being monitored in basic deployment"
  value       = module.keyvault_alerts_basic.monitored_key_vaults
}

output "basic_alert_summary" {
  description = "Summary of alerts configured for basic Key Vault deployment"
  value       = module.keyvault_alerts_basic.alert_summary
}
