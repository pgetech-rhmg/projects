# AMBA Alerts for Azure SQL Database
# This file contains comprehensive monitoring alerts for Azure SQL Database

# Get current client configuration
data "azurerm_client_config" "current" {}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Parse SQL Database names (format: server-name/database-name)
locals {
  databases = { for db in var.sql_database_names : db => {
    server_name   = split("/", db)[0]
    database_name = split("/", db)[1]
  } }

  # Cross-subscription support for Event Hub and Log Analytics
  eventhub_subscription_id      = var.eventhub_subscription_id != "" ? var.eventhub_subscription_id : data.azurerm_client_config.current.subscription_id
  log_analytics_subscription_id = var.log_analytics_subscription_id != "" ? var.log_analytics_subscription_id : data.azurerm_client_config.current.subscription_id
  eventhub_resource_group       = var.eventhub_resource_group_name != "" ? var.eventhub_resource_group_name : var.resource_group_name
  log_analytics_resource_group  = var.log_analytics_resource_group_name != "" ? var.log_analytics_resource_group_name : var.resource_group_name

  # Construct full resource IDs for cross-subscription support
  eventhub_namespace_id      = "/subscriptions/${local.eventhub_subscription_id}/resourceGroups/${local.eventhub_resource_group}/providers/Microsoft.EventHub/namespaces/${var.eventhub_namespace_name}"
  eventhub_id                = "${local.eventhub_namespace_id}/eventhubs/${var.eventhub_name}"
  eventhub_auth_rule_id      = "${local.eventhub_namespace_id}/authorizationRules/${var.eventhub_authorization_rule_name}"
  log_analytics_workspace_id = "/subscriptions/${local.log_analytics_subscription_id}/resourceGroups/${local.log_analytics_resource_group}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"

  # Simplified diagnostic settings flags
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.sql_database_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.sql_database_names) > 0
}

# Data source for SQL Databases using static names
data "azurerm_mssql_database" "sql_databases" {
  for_each  = local.databases
  name      = each.value.database_name
  server_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Sql/servers/${each.value.server_name}"
}

# CPU Utilization Alert
resource "azurerm_monitor_metric_alert" "sql_db_cpu_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-cpu-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database CPU utilization exceeds ${var.cpu_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-cpu-percent"
  })
}

# Storage Utilization Alert
resource "azurerm_monitor_metric_alert" "sql_db_storage_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-storage-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database storage utilization exceeds ${var.storage_percent_threshold}%"
  severity            = 1
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-storage-percent"
  })
}

# Storage Used Bytes Alert
resource "azurerm_monitor_metric_alert" "sql_db_storage_used_bytes" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-storage-used-bytes-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database storage used exceeds ${var.storage_used_bytes_threshold} bytes"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.storage_used_bytes_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-storage-used-bytes"
  })
}

# Connection Failed Alert
resource "azurerm_monitor_metric_alert" "sql_db_connection_failed" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-connection-failed-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database failed connections exceed ${var.connection_failed_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.connection_failed_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-connection-failed"
  })
}

# High Connection Successful Alert (indicates high load)
resource "azurerm_monitor_metric_alert" "sql_db_connection_successful_high" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-connection-successful-high-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database successful connections exceed ${var.connection_successful_threshold} (high load)"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_successful"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.connection_successful_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-connection-successful-high"
  })
}

# Deadlock Alert
resource "azurerm_monitor_metric_alert" "sql_db_deadlock" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-deadlock-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database deadlocks exceed ${var.deadlock_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.deadlock_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-deadlock"
  })
}

# Log Write Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_log_write_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-log-write-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database log write percentage exceeds ${var.log_write_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "log_write_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.log_write_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-log-write-percent"
  })
}

# Physical Data Read Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_physical_data_read_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-physical-data-read-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database physical data read percentage exceeds ${var.physical_data_read_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.physical_data_read_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-physical-data-read-percent"
  })
}

# Workers Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_workers_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-workers-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database workers percentage exceeds ${var.workers_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "workers_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.workers_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-workers-percent"
  })
}

# Sessions Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_sessions_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-sessions-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database sessions percentage exceeds ${var.sessions_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "sessions_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.sessions_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-sessions-percent"
  })
}

# SQL Server Process Core Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_sqlserver_process_core_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-sqlserver-process-core-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database process core percentage exceeds ${var.sqlserver_process_core_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "sqlserver_process_core_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.sqlserver_process_core_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-sqlserver-process-core-percent"
  })
}

# Tempdb Log Used Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_tempdb_log_used_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-tempdb-log-used-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database tempdb log used percentage exceeds ${var.tempdb_log_used_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "tempdb_log_used_percent"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.tempdb_log_used_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-tempdb-log-used-percent"
  })
}

# XTP Storage Percent Alert
resource "azurerm_monitor_metric_alert" "sql_db_xtp_storage_percent" {
  for_each            = data.azurerm_mssql_database.sql_databases
  name                = "sql-db-xtp-storage-percent-${replace(each.key, "/", "-")}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when SQL Database XTP storage percentage exceeds ${var.xtp_storage_percent_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "xtp_storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.xtp_storage_percent_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-db-xtp-storage-percent"
  })
}

# Activity Log Alert - SQL Database Deletion
resource "azurerm_monitor_activity_log_alert" "sql_database_delete" {
  count               = length(var.sql_database_names) > 0 ? 1 : 0
  name                = "sql-database-delete"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for db in data.azurerm_mssql_database.sql_databases : db.id]
  description         = "Alert when SQL Database is deleted"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Sql"
    resource_type     = "Microsoft.Sql/servers/databases"
    operation_name    = "Microsoft.Sql/servers/databases/delete"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-database-delete"
  })
}

# Activity Log Alert - SQL Database Configuration Changes
resource "azurerm_monitor_activity_log_alert" "sql_database_config_change" {
  count               = length(var.sql_database_names) > 0 ? 1 : 0
  name                = "sql-database-config-change"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for db in data.azurerm_mssql_database.sql_databases : db.id]
  description         = "Alert when SQL Database configuration is changed"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Sql"
    resource_type     = "Microsoft.Sql/servers/databases"
    operation_name    = "Microsoft.Sql/servers/databases/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sql-database-config-change"
  })
}

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "sql_db_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? local.databases : {}
  name                           = "sql-db-to-eventhub-${replace(each.key, "/", "-")}"
  target_resource_id             = data.azurerm_mssql_database.sql_databases[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  metric {
    category = "Basic"
    enabled  = false
  }

  metric {
    category = "InstanceAndAppAdvanced"
    enabled  = false
  }

  metric {
    category = "WorkloadManagement"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "sql_db_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? local.databases : {}
  name                       = "sql-db-to-loganalytics-${replace(each.key, "/", "-")}"
  target_resource_id         = data.azurerm_mssql_database.sql_databases[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  metric {
    category = "Basic"
    enabled  = true
  }

  metric {
    category = "InstanceAndAppAdvanced"
    enabled  = true
  }

  metric {
    category = "WorkloadManagement"
    enabled  = true
  }
}
