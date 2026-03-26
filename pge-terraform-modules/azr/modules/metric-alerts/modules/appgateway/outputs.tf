# Outputs for Azure Application Gateway AMBA Alerts Module

output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.compute_unit_utilization : "compute_unit_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.capacity_unit_utilization : "capacity_unit_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.unhealthy_host_count : "unhealthy_host_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.response_status_5xx : "response_5xx_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.response_status_4xx : "response_4xx_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.failed_requests : "failed_requests_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.backend_response_time : "backend_response_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.application_gateway_total_time : "total_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.backend_connect_time : "backend_connect_time_${k}" => v.id },
    { for k, v in azurerm_monitor_metric_alert.throughput : "throughput_${k}" => v.id }
  )
}

output "alert_names" {
  description = "Map of alert types to their full resource names"
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.compute_unit_utilization : "compute_unit_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.capacity_unit_utilization : "capacity_unit_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.unhealthy_host_count : "unhealthy_host_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.response_status_5xx : "response_5xx_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.response_status_4xx : "response_4xx_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.failed_requests : "failed_requests_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.backend_response_time : "backend_response_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.application_gateway_total_time : "total_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.backend_connect_time : "backend_connect_time_${k}" => v.name },
    { for k, v in azurerm_monitor_metric_alert.throughput : "throughput_${k}" => v.name }
  )
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting resource IDs by destination type and Application Gateway name"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.appgw_to_eventhub : k => v.id }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.appgw_to_loganalytics : k => v.id }
  }
}

output "diagnostic_setting_names" {
  description = "Map of diagnostic setting names by destination type and Application Gateway name"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.appgw_to_eventhub : k => v.name }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.appgw_to_loganalytics : k => v.name }
  }
}

output "monitored_application_gateways" {
  description = "List of Application Gateway names being monitored by this module"
  value       = var.application_gateway_names
}

output "action_group_id" {
  description = "The ID of the action group used for all alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "application_gateway_ids" {
  description = "Map of Application Gateway names to their resource IDs"
  value       = { for k, v in data.azurerm_application_gateway.app_gateways : k => v.id }
}
