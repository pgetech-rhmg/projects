# Azure Monitor Resources Monitoring Module Outputs

# Alert Resource IDs
output "alert_ids" {
  description = "List of all alert resource IDs created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion : alert.id],
    [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion_critical : alert.id],
    [for alert in azurerm_monitor_metric_alert.app_insights_availability : alert.id],
    [for alert in azurerm_monitor_metric_alert.app_insights_response_time : alert.id],
    [for alert in azurerm_monitor_metric_alert.app_insights_failed_requests : alert.id],
    [for alert in azurerm_monitor_metric_alert.app_insights_exceptions : alert.id]
  )
}

# Alert Names
output "alert_names" {
  description = "List of all alert names created by this module"
  value = concat(
    [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion : alert.name],
    [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion_critical : alert.name],
    [for alert in azurerm_monitor_metric_alert.app_insights_availability : alert.name],
    [for alert in azurerm_monitor_metric_alert.app_insights_response_time : alert.name],
    [for alert in azurerm_monitor_metric_alert.app_insights_failed_requests : alert.name],
    [for alert in azurerm_monitor_metric_alert.app_insights_exceptions : alert.name]
  )
}

# Monitored Resources
output "monitored_log_analytics_workspaces" {
  description = "List of Log Analytics workspace names being monitored"
  value       = var.log_analytics_workspace_names
}

output "monitored_application_insights" {
  description = "List of Application Insights resource names being monitored"
  value       = var.application_insights_names
}

output "monitored_data_collection_rules" {
  description = "List of Data Collection Rule names being monitored"
  value       = var.data_collection_rule_names
}

output "monitored_subscriptions" {
  description = "List of subscription IDs being monitored"
  value       = var.subscription_ids
}

output "monitored_resource_group" {
  description = "Resource group name where Azure Monitor resources are located"
  value       = var.resource_group_name
}

# Action Group Information
output "action_group_id" {
  description = "Resource ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}

# Alert Type Summary
output "alert_summary" {
  description = "Summary of alert types configured"
  value = {
    workspace_data_ingestion_alerts          = length(azurerm_monitor_metric_alert.workspace_data_ingestion)
    workspace_data_ingestion_critical_alerts = length(azurerm_monitor_metric_alert.workspace_data_ingestion_critical)
    app_insights_availability_alerts         = length(azurerm_monitor_metric_alert.app_insights_availability)
    app_insights_response_time_alerts        = length(azurerm_monitor_metric_alert.app_insights_response_time)
    app_insights_failed_requests_alerts      = length(azurerm_monitor_metric_alert.app_insights_failed_requests)
    app_insights_exceptions_alerts           = length(azurerm_monitor_metric_alert.app_insights_exceptions)
    total_metric_alerts = length(concat(
      [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion : alert.id],
      [for alert in azurerm_monitor_metric_alert.workspace_data_ingestion_critical : alert.id],
      [for alert in azurerm_monitor_metric_alert.app_insights_availability : alert.id],
      [for alert in azurerm_monitor_metric_alert.app_insights_response_time : alert.id],
      [for alert in azurerm_monitor_metric_alert.app_insights_failed_requests : alert.id],
      [for alert in azurerm_monitor_metric_alert.app_insights_exceptions : alert.id]
    ))
  }
}

# Alert Categories Status
output "alert_categories_enabled" {
  description = "Status of alert category enable flags"
  value = {
    workspace_alerts            = var.enable_workspace_alerts
    application_insights_alerts = var.enable_application_insights_alerts
    data_collection_alerts      = var.enable_data_collection_alerts
    monitor_service_alerts      = var.enable_monitor_service_alerts
    diagnostic_settings_alerts  = var.enable_diagnostic_settings_alerts
  }
}
