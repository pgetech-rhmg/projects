# Output the IDs of all created activity log alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    length(azurerm_monitor_activity_log_alert.defender_plan_status_change) > 0 ? {
      "defender_plan_status_change" = azurerm_monitor_activity_log_alert.defender_plan_status_change[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_policy_changes) > 0 ? {
      "security_policy_changes" = azurerm_monitor_activity_log_alert.security_policy_changes[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_policy_deletions) > 0 ? {
      "security_policy_deletions" = azurerm_monitor_activity_log_alert.security_policy_deletions[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_center_settings_changes) > 0 ? {
      "security_center_settings_changes" = azurerm_monitor_activity_log_alert.security_center_settings_changes[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_center_auto_provisioning_changes) > 0 ? {
      "security_center_auto_provisioning_changes" = azurerm_monitor_activity_log_alert.security_center_auto_provisioning_changes[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_assessment_changes) > 0 ? {
      "security_assessment_changes" = azurerm_monitor_activity_log_alert.security_assessment_changes[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.security_alert_rule_changes) > 0 ? {
      "security_alert_rule_changes" = azurerm_monitor_activity_log_alert.security_alert_rule_changes[0].id
    } : {},
    length(azurerm_monitor_activity_log_alert.workflow_automation_changes) > 0 ? {
      "workflow_automation_changes" = azurerm_monitor_activity_log_alert.workflow_automation_changes[0].id
    } : {}
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    length(azurerm_monitor_activity_log_alert.defender_plan_status_change) > 0 ? {
      "defender_plan_status_change" = azurerm_monitor_activity_log_alert.defender_plan_status_change[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_policy_changes) > 0 ? {
      "security_policy_changes" = azurerm_monitor_activity_log_alert.security_policy_changes[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_policy_deletions) > 0 ? {
      "security_policy_deletions" = azurerm_monitor_activity_log_alert.security_policy_deletions[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_center_settings_changes) > 0 ? {
      "security_center_settings_changes" = azurerm_monitor_activity_log_alert.security_center_settings_changes[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_center_auto_provisioning_changes) > 0 ? {
      "security_center_auto_provisioning_changes" = azurerm_monitor_activity_log_alert.security_center_auto_provisioning_changes[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_assessment_changes) > 0 ? {
      "security_assessment_changes" = azurerm_monitor_activity_log_alert.security_assessment_changes[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.security_alert_rule_changes) > 0 ? {
      "security_alert_rule_changes" = azurerm_monitor_activity_log_alert.security_alert_rule_changes[0].name
    } : {},
    length(azurerm_monitor_activity_log_alert.workflow_automation_changes) > 0 ? {
      "workflow_automation_changes" = azurerm_monitor_activity_log_alert.workflow_automation_changes[0].name
    } : {}
  )
}

# Output the monitored subscriptions
output "monitored_subscriptions" {
  description = "List of subscription IDs being monitored for Defender for Cloud alerts"
  value       = var.subscription_ids
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}

# Output feature flags
output "enabled_features" {
  description = "Summary of enabled alert features"
  value = {
    defender_plan_alerts = var.enable_defender_plan_alerts
    policy_alerts        = var.enable_policy_alerts
  }
}
