# Traffic Manager Profile Monitoring Outputs
# These outputs provide visibility into the monitoring configuration

# Metric Alert Outputs
output "endpoint_health_alert_ids" {
  description = "Map of Traffic Manager profile names to their endpoint health alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.endpoint_health : k => v.id
  }
}

output "probe_agent_endpoint_state_alert_ids" {
  description = "Map of Traffic Manager profile names to their probe agent endpoint state alert IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.probe_agent_endpoint_state : k => v.id
  }
}

# Activity Log Alert Outputs
output "traffic_manager_creation_alert_id" {
  description = "ID of the Traffic Manager profile creation alert"
  value       = try(azurerm_monitor_activity_log_alert.traffic_manager_creation[0].id, null)
}

output "traffic_manager_deletion_alert_id" {
  description = "ID of the Traffic Manager profile deletion alert"
  value       = try(azurerm_monitor_activity_log_alert.traffic_manager_deletion[0].id, null)
}

output "traffic_manager_config_change_alert_id" {
  description = "ID of the Traffic Manager configuration change alert"
  value       = try(azurerm_monitor_activity_log_alert.traffic_manager_config_change[0].id, null)
}

output "endpoint_operations_alert_id" {
  description = "ID of the Traffic Manager endpoint operations alert"
  value       = try(azurerm_monitor_activity_log_alert.endpoint_operations[0].id, null)
}

# Scheduled Query Rule Outputs
output "dns_resolution_failure_alert_id" {
  description = "ID of the DNS resolution failure scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.dns_resolution_failure[0].id, null)
}

output "endpoint_health_degradation_alert_id" {
  description = "ID of the endpoint health degradation scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.endpoint_health_degradation[0].id, null)
}

# Diagnostic Settings Outputs
output "diagnostic_setting_eventhub_ids" {
  description = "Map of Traffic Manager profile names to their Event Hub diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.trafficmanager_to_eventhub : k => v.id
  }
}

output "diagnostic_setting_loganalytics_ids" {
  description = "Map of Traffic Manager profile names to their Log Analytics diagnostic setting IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.trafficmanager_to_loganalytics : k => v.id
  }
}

# Monitored Resource Outputs
output "monitored_traffic_manager_profiles" {
  description = "Map of Traffic Manager profile names to their resource IDs"
  value = {
    for k, v in data.azurerm_traffic_manager_profile.traffic_manager_profiles : k => v.id
  }
}

# Action Group Output
output "action_group_id" {
  description = "ID of the action group used for alert notifications"
  value       = data.azurerm_monitor_action_group.action_group.id
}

# Configuration Summary
output "monitoring_configuration" {
  description = "Summary of the monitoring configuration for Traffic Manager profiles"
  value = {
    monitored_profiles_count    = length(var.traffic_manager_profile_names)
    monitored_profiles          = var.traffic_manager_profile_names
    metric_alerts_count         = 2
    activity_log_alerts_count   = 4
    scheduled_query_rules_count = 2
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_resource_group = var.action_group_resource_group_name
    action_group_name           = var.action_group
    resource_group              = var.resource_group_name

    alert_severities = {
      endpoint_health             = 1
      probe_agent_endpoint_state  = 2
      dns_resolution_failure      = 1
      endpoint_health_degradation = 2
    }

    enabled_alerts = {
      endpoint_health               = var.enable_endpoint_health_alert
      probe_agent_monitoring        = var.enable_probe_agent_monitoring_alert
      traffic_manager_creation      = var.enable_traffic_manager_creation_alert
      traffic_manager_deletion      = var.enable_traffic_manager_deletion_alert
      traffic_manager_config_change = var.enable_traffic_manager_config_change_alert
      endpoint_operations           = var.enable_endpoint_operations_alert
      dns_resolution_failure        = var.enable_dns_resolution_failure_alert
    }

    thresholds = {
      endpoint_health_threshold                                           = var.endpoint_health_threshold
      probe_agent_current_endpoint_state_by_profile_resource_id_threshold = var.probe_agent_current_endpoint_state_by_profile_resource_id_threshold
    }
  }
}
