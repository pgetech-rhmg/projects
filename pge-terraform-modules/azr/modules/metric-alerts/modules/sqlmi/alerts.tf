# SQL Managed Instance Metric Alerts

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Local variables for cross-subscription support
locals {
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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.sql_mi_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.sql_mi_names) > 0
}

# Data sources
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Get SQL Managed Instance information
data "azurerm_mssql_managed_instance" "sql_managed_instances" {
  count               = length(var.sql_mi_names)
  name                = var.sql_mi_names[count.index]
  resource_group_name = var.sql_mi_resource_group
}

# SQL MI CPU Utilization Warning Alert
resource "azurerm_monitor_metric_alert" "sqlmi_cpu_warning" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-cpu-warning-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]

  description   = "SQL Managed Instance CPU utilization is above warning threshold"
  severity      = 2
  enabled       = true
  auto_mitigate = true
  frequency     = var.evaluation_frequency
  window_size   = var.window_size

  criteria {
    metric_namespace = "Microsoft.Sql/managedInstances"
    metric_name      = "avg_cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_warning_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-cpu-warning-${var.sql_mi_names[count.index]}"
  })
}

# SQL MI CPU Utilization Critical Alert
resource "azurerm_monitor_metric_alert" "sqlmi_cpu_critical" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-cpu-critical-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]

  description   = "SQL Managed Instance CPU utilization is above critical threshold"
  severity      = 0
  enabled       = true
  auto_mitigate = true
  frequency     = var.evaluation_frequency
  window_size   = var.window_size

  criteria {
    metric_namespace = "Microsoft.Sql/managedInstances"
    metric_name      = "avg_cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-cpu-critical-${var.sql_mi_names[count.index]}"
  })
}

# SQL MI Storage Space Warning Alert
resource "azurerm_monitor_metric_alert" "sqlmi_storage_warning" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-storage-warning-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]

  description   = "SQL Managed Instance storage utilization is above warning threshold"
  severity      = 2
  enabled       = true
  auto_mitigate = true
  frequency     = var.evaluation_frequency
  window_size   = var.window_size

  criteria {
    metric_namespace = "Microsoft.Sql/managedInstances"
    metric_name      = "storage_space_used_mb"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_warning_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-storage-warning-${var.sql_mi_names[count.index]}"
  })
}

# SQL MI Storage Space Critical Alert
resource "azurerm_monitor_metric_alert" "sqlmi_storage_critical" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-storage-critical-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]

  description   = "SQL Managed Instance storage utilization is above critical threshold"
  severity      = 0
  enabled       = true
  auto_mitigate = true
  frequency     = var.evaluation_frequency
  window_size   = var.window_size

  criteria {
    metric_namespace = "Microsoft.Sql/managedInstances"
    metric_name      = "storage_space_used_mb"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-storage-critical-${var.sql_mi_names[count.index]}"
  })
}

# SQL MI vCore Utilization Warning Alert
resource "azurerm_monitor_metric_alert" "sqlmi_vcore_warning" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-vcore-warning-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]

  description   = "SQL Managed Instance vCore utilization is above warning threshold"
  severity      = 2
  enabled       = true
  auto_mitigate = true
  frequency     = var.evaluation_frequency
  window_size   = var.window_size

  criteria {
    metric_namespace = "Microsoft.Sql/managedInstances"
    metric_name      = "virtual_core_count"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_warning_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-vcore-warning-${var.sql_mi_names[count.index]}"
  })
}

# SQL MI Deletion Alert
resource "azurerm_monitor_activity_log_alert" "sqlmi_deletion" {
  count               = var.sql_mi_names != null && length(var.sql_mi_names) > 0 ? length(var.sql_mi_names) : 0
  name                = "sqlmi-deletion-${var.sql_mi_names[count.index]}"
  resource_group_name = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].resource_group_name
  scopes              = [data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id]
  location            = "global"

  description = "SQL Managed Instance has been deleted"
  enabled     = true

  criteria {
    resource_id    = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id
    operation_name = "Microsoft.Sql/managedInstances/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "sqlmi-deletion-${var.sql_mi_names[count.index]}"
  })
}

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "sqlmi_to_eventhub" {
  count                          = local.diagnostic_settings_eventhub_enabled ? length(var.sql_mi_names) : 0
  name                           = "sqlmi-to-eventhub-${var.sql_mi_names[count.index]}"
  target_resource_id             = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "ResourceUsageStats"
  }

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "DevOpsOperationsAudit"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "sqlmi_to_loganalytics" {
  count                      = local.diagnostic_settings_loganalytics_enabled ? length(var.sql_mi_names) : 0
  name                       = "sqlmi-to-loganalytics-${var.sql_mi_names[count.index]}"
  target_resource_id         = data.azurerm_mssql_managed_instance.sql_managed_instances[count.index].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "ResourceUsageStats"
  }

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "DevOpsOperationsAudit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
