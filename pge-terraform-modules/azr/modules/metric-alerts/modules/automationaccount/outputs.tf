# Outputs for Azure Automation Account AMBA Alerts Module

output "alert_ids" {
  description = "Map of all activity log alert resource IDs"
  value = {
    automation_account_creation  = length(azurerm_monitor_activity_log_alert.automation_account_creation) > 0 ? azurerm_monitor_activity_log_alert.automation_account_creation[0].id : null
    automation_account_deletion  = length(azurerm_monitor_activity_log_alert.automation_account_deletion) > 0 ? azurerm_monitor_activity_log_alert.automation_account_deletion[0].id : null
    runbook_operations           = length(azurerm_monitor_activity_log_alert.runbook_operations) > 0 ? azurerm_monitor_activity_log_alert.runbook_operations[0].id : null
    hybrid_worker_operations     = length(azurerm_monitor_activity_log_alert.hybrid_worker_operations) > 0 ? azurerm_monitor_activity_log_alert.hybrid_worker_operations[0].id : null
    update_deployment_operations = length(azurerm_monitor_activity_log_alert.update_deployment_operations) > 0 ? azurerm_monitor_activity_log_alert.update_deployment_operations[0].id : null
    webhook_operations           = length(azurerm_monitor_activity_log_alert.webhook_operations) > 0 ? azurerm_monitor_activity_log_alert.webhook_operations[0].id : null
  }
}

output "alert_names" {
  description = "Map of all activity log alert names"
  value = {
    automation_account_creation  = length(azurerm_monitor_activity_log_alert.automation_account_creation) > 0 ? azurerm_monitor_activity_log_alert.automation_account_creation[0].name : null
    automation_account_deletion  = length(azurerm_monitor_activity_log_alert.automation_account_deletion) > 0 ? azurerm_monitor_activity_log_alert.automation_account_deletion[0].name : null
    runbook_operations           = length(azurerm_monitor_activity_log_alert.runbook_operations) > 0 ? azurerm_monitor_activity_log_alert.runbook_operations[0].name : null
    hybrid_worker_operations     = length(azurerm_monitor_activity_log_alert.hybrid_worker_operations) > 0 ? azurerm_monitor_activity_log_alert.hybrid_worker_operations[0].name : null
    update_deployment_operations = length(azurerm_monitor_activity_log_alert.update_deployment_operations) > 0 ? azurerm_monitor_activity_log_alert.update_deployment_operations[0].name : null
    webhook_operations           = length(azurerm_monitor_activity_log_alert.webhook_operations) > 0 ? azurerm_monitor_activity_log_alert.webhook_operations[0].name : null
  }
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.automationaccount_to_eventhub : k => v.id }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.automationaccount_to_loganalytics : k => v.id }
  }
}

output "diagnostic_setting_names" {
  description = "Map of diagnostic setting names"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.automationaccount_to_eventhub : k => v.name }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.automationaccount_to_loganalytics : k => v.name }
  }
}

output "monitored_automation_accounts" {
  description = "List of monitored Automation Account names"
  value       = var.automation_account_names
}

output "monitored_subscriptions" {
  description = "List of monitored subscription IDs"
  value       = var.subscription_ids
}

output "action_group_id" {
  description = "The ID of the Action Group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}
