#
# Filename    : examples/alerts/outputs.tf
# Description : Outputs from Key Vault Monitoring example
#

output "availability_alert_ids" {
  value       = module.kv_monitoring.availability_alert_ids
  description = "IDs of the Key Vault availability alerts"
}

output "latency_alert_ids" {
  value       = module.kv_monitoring.latency_alert_ids
  description = "IDs of the Key Vault service API latency alerts"
}

output "access_policy_change_alert_id" {
  value       = module.kv_monitoring.access_policy_change_alert_id
  description = "ID of the Key Vault access policy change alert"
}

output "deletion_alert_id" {
  value       = module.kv_monitoring.deletion_alert_id
  description = "ID of the Key Vault deletion alert"
}

output "key_operations_alert_id" {
  value       = module.kv_monitoring.key_operations_alert_id
  description = "ID of the Key Vault key operations alert"
}
