# Azure Private DNS Zones Monitoring Module Outputs

# Alert Resource IDs
output "alert_ids" {
  description = "List of all alert resource IDs created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.dns_record_set_count : alert.id],
    [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_configuration_change : alert.id],
    [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_deletion : alert.id]
  )
}

# Alert Names
output "alert_names" {
  description = "List of all alert names created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.dns_record_set_count : alert.name],
    [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_configuration_change : alert.name],
    [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_deletion : alert.name]
  )
}

# Monitored Resources
output "monitored_dns_zones" {
  description = "List of Private DNS zone names being monitored"
  value       = var.dns_zone_names
}

output "monitored_resource_group" {
  description = "Resource group name where Private DNS zones are located"
  value       = var.resource_group_name
}

# Action Group Information
output "action_group_id" {
  description = "Resource ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Alert Type Summary
output "alert_summary" {
  description = "Summary of alert types configured"
  value = {
    record_set_count_alerts     = length(azurerm_monitor_metric_alert.dns_record_set_count)
    configuration_change_alerts = length(azurerm_monitor_activity_log_alert.private_dns_zone_configuration_change)
    deletion_alerts             = length(azurerm_monitor_activity_log_alert.private_dns_zone_deletion)
    total_metric_alerts         = length(azurerm_monitor_metric_alert.dns_record_set_count)
    total_activity_log_alerts   = length(azurerm_monitor_activity_log_alert.private_dns_zone_configuration_change) + length(azurerm_monitor_activity_log_alert.private_dns_zone_deletion)
    total_alerts = length(concat(
      [for alert in azurerm_monitor_metric_alert.dns_record_set_count : alert.id],
      [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_configuration_change : alert.id],
      [for alert in azurerm_monitor_activity_log_alert.private_dns_zone_deletion : alert.id]
    ))
  }
}
