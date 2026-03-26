/*
 * # Azure Key Vault Monitoring Outputs
*/
#
# Filename    : modules/key-vault-monitoring/outputs.tf
# Description : Output values from the Key Vault Monitoring module
#

output "availability_alert_ids" {
  value       = [for alert in azurerm_monitor_metric_alert.kv_availability : alert.id]
  description = "IDs of the Key Vault availability alerts"
}

output "latency_alert_ids" {
  value       = [for alert in azurerm_monitor_metric_alert.kv_service_api_latency : alert.id]
  description = "IDs of the Key Vault service API latency alerts"
}

output "access_policy_change_alert_id" {
  value       = try(azurerm_monitor_activity_log_alert.kv_access_policy_change[0].id, null)
  description = "ID of the Key Vault access policy change alert"
}

output "deletion_alert_id" {
  value       = try(azurerm_monitor_activity_log_alert.kv_delete[0].id, null)
  description = "ID of the Key Vault deletion alert"
}

output "key_operations_alert_id" {
  value       = try(azurerm_monitor_activity_log_alert.kv_key_operations[0].id, null)
  description = "ID of the Key Vault key operations alert"
}
