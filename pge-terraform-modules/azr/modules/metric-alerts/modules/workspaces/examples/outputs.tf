#======================================================================================
# Production Workspace Monitoring Outputs
#======================================================================================

output "production_monitoring_summary" {
  description = "Summary of production workspace monitoring configuration"
  value = {
    workspaces_monitored = length(module.workspace_monitoring_production.monitored_workspace_names)
    workspace_names      = module.workspace_monitoring_production.monitored_workspace_names
    alerts_configuration = module.workspace_monitoring_production.monitoring_configuration
  }
}

output "production_alert_ids" {
  description = "Alert IDs for production workspace monitoring"
  value = {
    heartbeat_alert         = module.workspace_monitoring_production.workspace_heartbeat_alert_id
    query_performance_alert = module.workspace_monitoring_production.workspace_query_performance_alert_id
    data_retention_alert    = module.workspace_monitoring_production.workspace_data_retention_alert_id
    error_rate_alert        = module.workspace_monitoring_production.workspace_error_rate_alert_id
    agent_connection_alert  = module.workspace_monitoring_production.workspace_agent_connection_alert_id
    custom_table_alert      = module.workspace_monitoring_production.workspace_custom_table_ingestion_alert_id
  }
}

output "production_diagnostic_settings" {
  description = "Diagnostic setting IDs for production workspaces"
  value = {
    eventhub_settings      = module.workspace_monitoring_production.diagnostic_setting_eventhub_ids
    log_analytics_settings = module.workspace_monitoring_production.diagnostic_setting_loganalytics_ids
  }
}

#======================================================================================
# Development Workspace Monitoring Outputs
#======================================================================================

output "development_monitoring_summary" {
  description = "Summary of development workspace monitoring configuration"
  value = {
    workspaces_monitored = length(module.workspace_monitoring_development.monitored_workspace_names)
    workspace_names      = module.workspace_monitoring_development.monitored_workspace_names
    alerts_configuration = module.workspace_monitoring_development.monitoring_configuration
  }
}

output "development_alert_ids" {
  description = "Alert IDs for development workspace monitoring"
  value = {
    heartbeat_alert         = module.workspace_monitoring_development.workspace_heartbeat_alert_id
    query_performance_alert = module.workspace_monitoring_development.workspace_query_performance_alert_id
    error_rate_alert        = module.workspace_monitoring_development.workspace_error_rate_alert_id
  }
}

#======================================================================================
# Basic Workspace Monitoring Outputs
#======================================================================================

output "basic_monitoring_summary" {
  description = "Summary of basic workspace monitoring configuration"
  value = {
    workspaces_monitored = length(module.workspace_monitoring_basic.monitored_workspace_names)
    workspace_names      = module.workspace_monitoring_basic.monitored_workspace_names
    alerts_configuration = module.workspace_monitoring_basic.monitoring_configuration
  }
}

output "basic_alert_ids" {
  description = "Alert IDs for basic workspace monitoring"
  value = {
    heartbeat_alert = module.workspace_monitoring_basic.workspace_heartbeat_alert_id
  }
}

#======================================================================================
# Comparison Outputs
#======================================================================================

output "environment_comparison" {
  description = "Comparison of monitoring configurations across environments"
  value = {
    production = {
      workspaces     = length(module.workspace_monitoring_production.monitored_workspace_names)
      alerts_enabled = 6
      diagnostics    = "Event Hub + Log Analytics"
      retention_days = 90
    }
    development = {
      workspaces     = length(module.workspace_monitoring_development.monitored_workspace_names)
      alerts_enabled = 3
      diagnostics    = "Log Analytics Only"
      retention_days = 30
    }
    basic = {
      workspaces     = length(module.workspace_monitoring_basic.monitored_workspace_names)
      alerts_enabled = 1
      diagnostics    = "None"
      retention_days = 30
    }
  }
}

output "alert_status_production" {
  description = "Status of all alerts in production environment"
  value       = module.workspace_monitoring_production.alert_status
}

output "alert_status_development" {
  description = "Status of all alerts in development environment"
  value       = module.workspace_monitoring_development.alert_status
}

output "alert_status_basic" {
  description = "Status of all alerts in basic environment"
  value       = module.workspace_monitoring_basic.alert_status
}
