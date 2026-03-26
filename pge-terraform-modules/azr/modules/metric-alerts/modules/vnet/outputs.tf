# Virtual Network Monitoring Outputs
# These outputs provide visibility into the monitoring configuration

# Metric Alert Outputs
output "if_under_ddos_attack_alert_ids" {
  description = "Map of VNet names to their DDoS attack alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.if_under_DDOS_Attack : k => v.id
  }
}

# Diagnostic Settings Outputs
output "diagnostic_setting_eventhub_ids" {
  description = "Map of VNet names to their Event Hub diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.vnet_to_eventhub : k => v.id
  }
}

output "diagnostic_setting_loganalytics_ids" {
  description = "Map of VNet names to their Log Analytics diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.vnet_to_loganalytics : k => v.id
  }
}

# Monitored Resource Outputs
output "monitored_vnets" {
  description = "Map of VNet names to their resource IDs"
  value = {
    for k, v in data.azurerm_virtual_network.vnets : k => v.id
  }
}

# Action Group Output
output "action_group_id" {
  description = "ID of the action group used for alert notifications"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Configuration Summary
output "monitoring_configuration" {
  description = "Summary of the monitoring configuration for Virtual Networks"
  value = {
    monitored_vnets_count       = length(var.vnet_names)
    monitored_vnets             = var.vnet_names
    metric_alerts_count         = 1
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_resource_group = var.action_group_resource_group_name
    action_group_name           = var.action_group
    resource_group              = var.resource_group_name

    alert_severities = {
      if_under_ddos_attack = 1
    }

    thresholds = {
      if_under_ddos_attack = var.vnet_if_under_ddos_attack_threshold
    }
  }
}
