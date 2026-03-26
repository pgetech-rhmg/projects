# Outputs for Azure Application Insights AMBA Alerts Module

output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.availability : "availability_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.response_time : "response_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.server_response_time : "server_response_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.dependency_duration : "dependency_duration_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.page_view_load_time : "page_view_load_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.exception_rate : "exception_rate_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.failed_requests : "failed_requests_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.dependency_failure_rate : "dependency_failure_rate_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.request_rate : "request_rate_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.page_view_count : "page_view_count_${k}" => v.id }
  )
}

output "alert_names" {
  description = "Map of alert types to their full resource names"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.availability : "availability_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.response_time : "response_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.server_response_time : "server_response_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.dependency_duration : "dependency_duration_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.page_view_load_time : "page_view_load_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.exception_rate : "exception_rate_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.failed_requests : "failed_requests_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.dependency_failure_rate : "dependency_failure_rate_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.request_rate : "request_rate_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.page_view_count : "page_view_count_${k}" => v.name }
  )
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting resource IDs by destination type and Application Insights name"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.appinsights_to_eventhub : k => v.id }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.appinsights_to_loganalytics : k => v.id }
  }
}

output "diagnostic_setting_names" {
  description = "Map of diagnostic setting names by destination type and Application Insights name"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.appinsights_to_eventhub : k => v.name }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.appinsights_to_loganalytics : k => v.name }
  }
}

output "monitored_application_insights" {
  description = "List of Application Insights names being monitored by this module"
  value       = var.application_insights_names
}

output "action_group_id" {
  description = "The ID of the action group used for all alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}

output "application_insights_ids" {
  description = "Map of Application Insights names to their resource IDs"
  value       = { for k, v in data.azurerm_application_insights.app_insights : k => v.id }
}
