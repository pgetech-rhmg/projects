# Outputs for SQL Database Monitoring Module

# Alert Resource IDs
output "alert_ids" {
  description = "Map of alert resource IDs by alert type"
  value = {
    cpu_percent                    = { for k, v in azurerm_monitor_metric_alert.sql_db_cpu_percent : k => v.id }
    storage_percent                = { for k, v in azurerm_monitor_metric_alert.sql_db_storage_percent : k => v.id }
    storage_used_bytes             = { for k, v in azurerm_monitor_metric_alert.sql_db_storage_used_bytes : k => v.id }
    connection_failed              = { for k, v in azurerm_monitor_metric_alert.sql_db_connection_failed : k => v.id }
    connection_successful_high     = { for k, v in azurerm_monitor_metric_alert.sql_db_connection_successful_high : k => v.id }
    deadlock                       = { for k, v in azurerm_monitor_metric_alert.sql_db_deadlock : k => v.id }
    log_write_percent              = { for k, v in azurerm_monitor_metric_alert.sql_db_log_write_percent : k => v.id }
    physical_data_read_percent     = { for k, v in azurerm_monitor_metric_alert.sql_db_physical_data_read_percent : k => v.id }
    workers_percent                = { for k, v in azurerm_monitor_metric_alert.sql_db_workers_percent : k => v.id }
    sessions_percent               = { for k, v in azurerm_monitor_metric_alert.sql_db_sessions_percent : k => v.id }
    sqlserver_process_core_percent = { for k, v in azurerm_monitor_metric_alert.sql_db_sqlserver_process_core_percent : k => v.id }
    tempdb_log_used_percent        = { for k, v in azurerm_monitor_metric_alert.sql_db_tempdb_log_used_percent : k => v.id }
    xtp_storage_percent            = { for k, v in azurerm_monitor_metric_alert.sql_db_xtp_storage_percent : k => v.id }
  }
}

# Alert Names
output "alert_names" {
  description = "Map of alert names by alert type"
  value = {
    cpu_percent                    = { for k, v in azurerm_monitor_metric_alert.sql_db_cpu_percent : k => v.name }
    storage_percent                = { for k, v in azurerm_monitor_metric_alert.sql_db_storage_percent : k => v.name }
    storage_used_bytes             = { for k, v in azurerm_monitor_metric_alert.sql_db_storage_used_bytes : k => v.name }
    connection_failed              = { for k, v in azurerm_monitor_metric_alert.sql_db_connection_failed : k => v.name }
    connection_successful_high     = { for k, v in azurerm_monitor_metric_alert.sql_db_connection_successful_high : k => v.name }
    deadlock                       = { for k, v in azurerm_monitor_metric_alert.sql_db_deadlock : k => v.name }
    log_write_percent              = { for k, v in azurerm_monitor_metric_alert.sql_db_log_write_percent : k => v.name }
    physical_data_read_percent     = { for k, v in azurerm_monitor_metric_alert.sql_db_physical_data_read_percent : k => v.name }
    workers_percent                = { for k, v in azurerm_monitor_metric_alert.sql_db_workers_percent : k => v.name }
    sessions_percent               = { for k, v in azurerm_monitor_metric_alert.sql_db_sessions_percent : k => v.name }
    sqlserver_process_core_percent = { for k, v in azurerm_monitor_metric_alert.sql_db_sqlserver_process_core_percent : k => v.name }
    tempdb_log_used_percent        = { for k, v in azurerm_monitor_metric_alert.sql_db_tempdb_log_used_percent : k => v.name }
    xtp_storage_percent            = { for k, v in azurerm_monitor_metric_alert.sql_db_xtp_storage_percent : k => v.name }
  }
}

# Monitored Resources
output "monitored_resources" {
  description = "Map of monitored SQL Database resource IDs"
  value = {
    database_ids   = { for k, v in data.azurerm_mssql_database.sql_databases : k => v.id }
    database_names = var.sql_database_names
    database_count = length(var.sql_database_names)
  }
}

# Action Group
output "action_group_id" {
  description = "The ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.pge_operations.id
}

# Diagnostic Settings
output "diagnostic_settings" {
  description = "Map of diagnostic setting resource IDs"
  value = {
    eventhub     = { for k, v in azurerm_monitor_diagnostic_setting.sql_db_to_eventhub : k => v.id }
    loganalytics = { for k, v in azurerm_monitor_diagnostic_setting.sql_db_to_loganalytics : k => v.id }
  }
}

# Configuration Summary
output "alert_summary" {
  description = "Summary of alert configuration"
  value = {
    total_alerts        = 13
    databases_monitored = length(var.sql_database_names)
    alert_categories = {
      performance_alerts = 7
      storage_alerts     = 3
      connection_alerts  = 2
      health_alerts      = 1
    }
    configured_thresholds = {
      cpu_percent                    = var.cpu_percent_threshold
      storage_percent                = var.storage_percent_threshold
      storage_used_bytes             = var.storage_used_bytes_threshold
      connection_successful          = var.connection_successful_threshold
      connection_failed              = var.connection_failed_threshold
      deadlock                       = var.deadlock_threshold
      log_write_percent              = var.log_write_percent_threshold
      physical_data_read_percent     = var.physical_data_read_percent_threshold
      workers_percent                = var.workers_percent_threshold
      sessions_percent               = var.sessions_percent_threshold
      sqlserver_process_core_percent = var.sqlserver_process_core_percent_threshold
      tempdb_log_used_percent        = var.tempdb_log_used_percent_threshold
      xtp_storage_percent            = var.xtp_storage_percent_threshold
    }
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    action_group_name           = var.action_group
  }
}
