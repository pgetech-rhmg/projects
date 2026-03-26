# Output: Scheduled Query Rule Alert IDs
output "workspace_heartbeat_alert_id" {
  description = "ID of the Log Analytics Workspace heartbeat alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_heartbeat) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_heartbeat[0].id : null
}

output "workspace_query_performance_alert_id" {
  description = "ID of the Log Analytics Workspace query performance alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_query_performance) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_query_performance[0].id : null
}

output "workspace_data_retention_alert_id" {
  description = "ID of the Log Analytics Workspace data retention alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_data_retention) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_data_retention[0].id : null
}

output "workspace_error_rate_alert_id" {
  description = "ID of the Log Analytics Workspace error rate alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_error_rate) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_error_rate[0].id : null
}

output "workspace_agent_connection_alert_id" {
  description = "ID of the Log Analytics Workspace agent connection alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_agent_connection) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_agent_connection[0].id : null
}

output "workspace_custom_table_ingestion_alert_id" {
  description = "ID of the Log Analytics Workspace custom table ingestion alert"
  value       = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_custom_table_ingestion) > 0 ? azurerm_monitor_scheduled_query_rules_alert_v2.workspace_custom_table_ingestion[0].id : null
}

# Output: Diagnostic Setting IDs
output "diagnostic_setting_eventhub_ids" {
  description = "Map of workspace names to Event Hub diagnostic setting IDs"
  value = {
    for name, setting in azurerm_monitor_diagnostic_setting.workspace_to_eventhub : name => setting.id
  }
}

output "diagnostic_setting_loganalytics_ids" {
  description = "Map of workspace names to Log Analytics diagnostic setting IDs"
  value = {
    for name, setting in azurerm_monitor_diagnostic_setting.workspace_to_loganalytics : name => setting.id
  }
}

# Output: Monitored Resources
output "monitored_workspace_ids" {
  description = "List of Log Analytics Workspace resource IDs being monitored"
  value       = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
}

output "monitored_workspace_names" {
  description = "List of Log Analytics Workspace names being monitored"
  value       = var.workspace_names
}

# Output: Configuration Summary
output "monitoring_configuration" {
  description = "Summary of monitoring configuration for Log Analytics Workspaces"
  value = {
    workspaces_monitored    = length(var.workspace_names)
    workspace_names         = var.workspace_names
    custom_tables_monitored = var.workspace_custom_tables
    alerts_enabled = {
      heartbeat_alert         = var.enable_workspace_heartbeat_alert
      query_performance_alert = var.enable_workspace_query_performance_alert
      data_retention_alert    = var.enable_workspace_data_retention_alert
      error_rate_alert        = var.enable_workspace_error_rate_alert
      agent_connection_alert  = var.enable_workspace_agent_connection_alert
      custom_table_alert      = var.enable_workspace_custom_table_alert
    }
    alert_thresholds = {
      heartbeat_threshold         = var.workspace_heartbeat_threshold
      query_performance_threshold = var.workspace_query_performance_threshold
      error_rate_threshold        = var.workspace_error_rate_threshold
      agent_connection_threshold  = var.workspace_agent_connection_threshold
      custom_table_threshold      = var.workspace_custom_table_threshold
    }
    retention_configuration = {
      retention_days         = var.workspace_retention_days
      retention_warning_days = var.workspace_retention_warning_days
    }
    diagnostic_settings = {
      enabled                      = var.enable_diagnostic_settings
      eventhub_enabled             = local.diagnostic_settings_eventhub_enabled
      log_analytics_enabled        = local.diagnostic_settings_loganalytics_enabled
      eventhub_name                = var.eventhub_name
      log_analytics_workspace_name = var.log_analytics_workspace_name
    }
    action_group = {
      name           = var.action_group
      resource_group = var.action_group_resource_group_name
    }
  }
}

# Output: Alert Status
output "alert_status" {
  description = "Status of each alert type (enabled/disabled)"
  value = {
    heartbeat_alert = {
      enabled   = var.enable_workspace_heartbeat_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_heartbeat) > 0
      severity  = 2
      frequency = "PT5M"
    }
    query_performance_alert = {
      enabled   = var.enable_workspace_query_performance_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_query_performance) > 0
      severity  = 3
      frequency = "PT15M"
    }
    data_retention_alert = {
      enabled   = var.enable_workspace_data_retention_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_data_retention) > 0
      severity  = 3
      frequency = "P1D"
    }
    error_rate_alert = {
      enabled   = var.enable_workspace_error_rate_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_error_rate) > 0
      severity  = 2
      frequency = "PT15M"
    }
    agent_connection_alert = {
      enabled   = var.enable_workspace_agent_connection_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_agent_connection) > 0
      severity  = 3
      frequency = "PT15M"
    }
    custom_table_alert = {
      enabled   = var.enable_workspace_custom_table_alert
      created   = length(azurerm_monitor_scheduled_query_rules_alert_v2.workspace_custom_table_ingestion) > 0
      severity  = 3
      frequency = "PT30M"
    }
  }
}
