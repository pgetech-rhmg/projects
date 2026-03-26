# Outputs for Azure App Service Environment AMBA Alerts Module

output "alert_ids" {
  description = "Map of all metric alert resource IDs"
  value = {
    cpu_percentage                    = { for k, v in azurerm_monitor_metric_alert.ase_cpu_percentage : k => v.id }
    memory_percentage                 = { for k, v in azurerm_monitor_metric_alert.ase_memory_percentage : k => v.id }
    large_app_service_plan_instances  = { for k, v in azurerm_monitor_metric_alert.ase_large_app_service_plan_instances : k => v.id }
    medium_app_service_plan_instances = { for k, v in azurerm_monitor_metric_alert.ase_medium_app_service_plan_instances : k => v.id }
    small_app_service_plan_instances  = { for k, v in azurerm_monitor_metric_alert.ase_small_app_service_plan_instances : k => v.id }
    total_front_end_instances         = { for k, v in azurerm_monitor_metric_alert.ase_total_front_end_instances : k => v.id }
    data_in                           = { for k, v in azurerm_monitor_metric_alert.ase_data_in : k => v.id }
    data_out                          = { for k, v in azurerm_monitor_metric_alert.ase_data_out : k => v.id }
    average_response_time             = { for k, v in azurerm_monitor_metric_alert.ase_average_response_time : k => v.id }
    http_queue_length                 = { for k, v in azurerm_monitor_metric_alert.ase_http_queue_length : k => v.id }
    http_4xx                          = { for k, v in azurerm_monitor_metric_alert.ase_http_4xx : k => v.id }
    http_5xx                          = { for k, v in azurerm_monitor_metric_alert.ase_http_5xx : k => v.id }
    http_401                          = { for k, v in azurerm_monitor_metric_alert.ase_http_401 : k => v.id }
    http_403                          = { for k, v in azurerm_monitor_metric_alert.ase_http_403 : k => v.id }
    http_404                          = { for k, v in azurerm_monitor_metric_alert.ase_http_404 : k => v.id }
    total_requests                    = { for k, v in azurerm_monitor_metric_alert.ase_total_requests : k => v.id }
  }
}

output "alert_names" {
  description = "Map of all metric alert names"
  value = {
    cpu_percentage                    = { for k, v in azurerm_monitor_metric_alert.ase_cpu_percentage : k => v.name }
    memory_percentage                 = { for k, v in azurerm_monitor_metric_alert.ase_memory_percentage : k => v.name }
    large_app_service_plan_instances  = { for k, v in azurerm_monitor_metric_alert.ase_large_app_service_plan_instances : k => v.name }
    medium_app_service_plan_instances = { for k, v in azurerm_monitor_metric_alert.ase_medium_app_service_plan_instances : k => v.name }
    small_app_service_plan_instances  = { for k, v in azurerm_monitor_metric_alert.ase_small_app_service_plan_instances : k => v.name }
    total_front_end_instances         = { for k, v in azurerm_monitor_metric_alert.ase_total_front_end_instances : k => v.name }
    data_in                           = { for k, v in azurerm_monitor_metric_alert.ase_data_in : k => v.name }
    data_out                          = { for k, v in azurerm_monitor_metric_alert.ase_data_out : k => v.name }
    average_response_time             = { for k, v in azurerm_monitor_metric_alert.ase_average_response_time : k => v.name }
    http_queue_length                 = { for k, v in azurerm_monitor_metric_alert.ase_http_queue_length : k => v.name }
    http_4xx                          = { for k, v in azurerm_monitor_metric_alert.ase_http_4xx : k => v.name }
    http_5xx                          = { for k, v in azurerm_monitor_metric_alert.ase_http_5xx : k => v.name }
    http_401                          = { for k, v in azurerm_monitor_metric_alert.ase_http_401 : k => v.name }
    http_403                          = { for k, v in azurerm_monitor_metric_alert.ase_http_403 : k => v.name }
    http_404                          = { for k, v in azurerm_monitor_metric_alert.ase_http_404 : k => v.name }
    total_requests                    = { for k, v in azurerm_monitor_metric_alert.ase_total_requests : k => v.name }
  }
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.ase_to_eventhub : k => v.id }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.ase_to_loganalytics : k => v.id }
  }
}

output "diagnostic_setting_names" {
  description = "Map of diagnostic setting names"
  value = {
    eventhub      = { for k, v in azurerm_monitor_diagnostic_setting.ase_to_eventhub : k => v.name }
    log_analytics = { for k, v in azurerm_monitor_diagnostic_setting.ase_to_loganalytics : k => v.name }
  }
}

output "monitored_ases" {
  description = "Map of monitored App Service Environment resources"
  value = {
    for k, v in data.azurerm_app_service_environment_v3.ases : k => {
      id       = v.id
      name     = v.name
      location = v.location
    }
  }
}

output "action_group_id" {
  description = "The ID of the Action Group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

output "ase_ids" {
  description = "Map of App Service Environment resource IDs"
  value       = { for k, v in data.azurerm_app_service_environment_v3.ases : k => v.id }
}
