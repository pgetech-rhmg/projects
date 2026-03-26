# Outputs from the Automation Account monitoring module examples

# Production deployment outputs
output "production_alert_ids" {
  description = "Map of alert IDs from production deployment"
  value       = module.automation_account_alerts_production.alert_ids
}

output "production_alert_names" {
  description = "Map of alert names from production deployment"
  value       = module.automation_account_alerts_production.alert_names
}

output "production_diagnostic_settings" {
  description = "Diagnostic settings IDs from production deployment"
  value       = module.automation_account_alerts_production.diagnostic_setting_ids
}

output "production_monitored_accounts" {
  description = "List of Automation Accounts being monitored in production"
  value       = module.automation_account_alerts_production.monitored_automation_accounts
}

# Development deployment outputs
output "dev_alert_ids" {
  description = "Map of alert IDs from development deployment"
  value       = module.automation_account_alerts_dev.alert_ids
}

output "dev_monitored_accounts" {
  description = "List of Automation Accounts being monitored in development"
  value       = module.automation_account_alerts_dev.monitored_automation_accounts
}

# Basic deployment outputs
output "basic_alert_ids" {
  description = "Map of alert IDs from basic deployment"
  value       = module.automation_account_alerts_basic.alert_ids
}

output "basic_monitored_accounts" {
  description = "List of Automation Accounts being monitored in basic deployment"
  value       = module.automation_account_alerts_basic.monitored_automation_accounts
}
