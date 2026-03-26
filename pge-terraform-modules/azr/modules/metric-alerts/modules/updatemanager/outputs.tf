# Azure Update Manager Monitoring Outputs
# These outputs provide visibility into the monitoring configuration

# Activity Log Alert Outputs
output "update_deployment_started_alert_id" {
  description = "ID of the update deployment started alert"
  value       = try(azurerm_monitor_activity_log_alert.update_deployment_started[0].id, null)
}

output "update_deployment_failed_alert_id" {
  description = "ID of the update deployment failed alert"
  value       = try(azurerm_monitor_activity_log_alert.update_deployment_failed[0].id, null)
}

output "maintenance_config_change_alert_id" {
  description = "ID of the maintenance configuration change alert"
  value       = try(azurerm_monitor_activity_log_alert.maintenance_config_change[0].id, null)
}

output "maintenance_config_deleted_alert_id" {
  description = "ID of the maintenance configuration deleted alert"
  value       = try(azurerm_monitor_activity_log_alert.maintenance_config_deleted[0].id, null)
}

output "update_assessment_triggered_alert_id" {
  description = "ID of the update assessment triggered alert"
  value       = try(azurerm_monitor_activity_log_alert.update_assessment_triggered[0].id, null)
}

output "vm_update_failed_alert_id" {
  description = "ID of the VM update failed alert"
  value       = try(azurerm_monitor_activity_log_alert.vm_update_failed[0].id, null)
}

# Scheduled Query Rule Outputs
output "update_compliance_low_alert_id" {
  description = "ID of the update compliance low scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.update_compliance_low[0].id, null)
}

output "critical_updates_available_alert_id" {
  description = "ID of the critical updates available scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.critical_updates_available[0].id, null)
}

output "update_installation_failures_alert_id" {
  description = "ID of the update installation failures scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.update_installation_failures[0].id, null)
}

output "update_assessment_failures_alert_id" {
  description = "ID of the update assessment failures scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.update_assessment_failures[0].id, null)
}

output "maintenance_window_violations_alert_id" {
  description = "ID of the maintenance window violations scheduled query rule alert"
  value       = try(azurerm_monitor_scheduled_query_rules_alert_v2.maintenance_window_violations[0].id, null)
}

# Action Group Output
output "action_group_id" {
  description = "ID of the action group used for alert notifications"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Monitored Resource Outputs
output "monitored_subscription_ids" {
  description = "List of subscription IDs being monitored"
  value       = var.subscription_ids
}

output "monitored_vm_resource_ids" {
  description = "List of VM resource IDs being monitored for update compliance"
  value       = var.vm_resource_ids
}

# Configuration Summary
output "monitoring_configuration" {
  description = "Summary of the monitoring configuration for Azure Update Manager"
  value = {
    monitored_subscriptions_count = length(var.subscription_ids)
    monitored_vms_count           = length(var.vm_resource_ids)
    activity_log_alerts_count     = 6
    scheduled_query_rules_count   = 6
    action_group_resource_group   = var.action_group_resource_group_name
    action_group_name             = var.action_group
    resource_group                = var.resource_group_name
    location                      = var.location

    alert_severities = {
      update_compliance_low         = 2
      critical_updates_available    = 1
      update_installation_failures  = 1
      update_assessment_failures    = 2
      maintenance_window_violations = 2
    }

    enabled_alerts = {
      update_deployment_failure  = var.enable_update_deployment_failure_alert
      update_compliance          = var.enable_update_compliance_alert
      maintenance_window         = var.enable_maintenance_window_alert
      patch_installation_failure = var.enable_patch_installation_failure_alert
      update_assessment_failure  = var.enable_update_assessment_failure_alert
      critical_update_available  = var.enable_critical_update_available_alert
    }

    thresholds = {
      update_deployment_failure  = var.update_deployment_failure_threshold
      update_compliance          = var.update_compliance_threshold
      patch_installation_failure = var.patch_installation_failure_threshold
      update_assessment_failure  = var.update_assessment_failure_threshold
      critical_update_available  = var.critical_update_available_threshold
      maintenance_window         = var.maintenance_window_threshold
    }
  }
}
