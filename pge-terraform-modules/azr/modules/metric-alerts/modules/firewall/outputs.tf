# Output the IDs of all created metric alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = {
    for k, v in merge(
      azurerm_monitor_metric_alert.firewall_health,
      azurerm_monitor_metric_alert.snat_port_utilization,
      azurerm_monitor_metric_alert.firewall_throughput,
      azurerm_monitor_metric_alert.firewall_latency,
      azurerm_monitor_metric_alert.data_processed,
      azurerm_monitor_metric_alert.application_rule_hit,
      azurerm_monitor_metric_alert.network_rule_hit
    ) : k => v.id
  }
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = {
    for k, v in merge(
      azurerm_monitor_metric_alert.firewall_health,
      azurerm_monitor_metric_alert.snat_port_utilization,
      azurerm_monitor_metric_alert.firewall_throughput,
      azurerm_monitor_metric_alert.firewall_latency,
      azurerm_monitor_metric_alert.data_processed,
      azurerm_monitor_metric_alert.application_rule_hit,
      azurerm_monitor_metric_alert.network_rule_hit
    ) : k => v.name
  }
}

# Output the monitored firewall names
output "monitored_firewalls" {
  description = "List of Azure Firewall names being monitored"
  value       = var.firewall_names
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}
