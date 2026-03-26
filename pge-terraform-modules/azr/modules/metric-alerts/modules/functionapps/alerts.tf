# Azure Function Apps AMBA Alerts
# This file contains comprehensive monitoring alerts for Azure Function Apps (Windows and Linux) following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.windows_function_app_names) > 0 || length(var.linux_function_app_names) > 0
  subscription_scopes  = var.subscription_ids != [] ? [for id in var.subscription_ids : "/subscriptions/${id}"] : []

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && local.should_create_alerts
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && local.should_create_alerts
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Windows Function Apps
data "azurerm_windows_function_app" "windows_function_apps" {
  for_each            = local.should_create_alerts ? toset(var.windows_function_app_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data source for Linux Function Apps
data "azurerm_linux_function_app" "linux_function_apps" {
  for_each            = local.should_create_alerts ? toset(var.linux_function_app_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Combine Windows and Linux Function Apps for unified alerting
locals {
  all_function_apps = merge(
    { for k, v in data.azurerm_windows_function_app.windows_function_apps : "win-${k}" => v },
    { for k, v in data.azurerm_linux_function_app.linux_function_apps : "linux-${k}" => v }
  )

  # Windows-only function apps for .NET specific metrics (garbage collection)
  windows_function_apps = var.enable_resource_alerts && local.should_create_alerts ? { for k, v in data.azurerm_windows_function_app.windows_function_apps : "win-${k}" => v } : tomap({})

  # Filtered function apps for different alert categories
  function_execution_apps = var.enable_function_execution_alerts && local.should_create_alerts ? local.all_function_apps : tomap({})
  performance_apps        = var.enable_performance_alerts && local.should_create_alerts ? local.all_function_apps : tomap({})
  error_apps              = var.enable_error_alerts && local.should_create_alerts ? local.all_function_apps : tomap({})
  resource_apps           = var.enable_resource_alerts && local.should_create_alerts ? local.all_function_apps : tomap({})
}

# =======================================================================================
# FUNCTION EXECUTION ALERTS
# =======================================================================================

# Function Execution Count Alert
resource "azurerm_monitor_metric_alert" "function_execution_count" {
  for_each            = local.function_execution_apps
  name                = "func-execution-count-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} execution count exceeds threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "FunctionExecutionCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.function_execution_count_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "FunctionExecution"
  })
}

# Function Execution Units Alert
resource "azurerm_monitor_metric_alert" "function_execution_units" {
  for_each            = local.function_execution_apps
  name                = "func-execution-units-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} execution units exceed threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "FunctionExecutionUnits"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.function_execution_units_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "FunctionExecutionUnits"
  })
}

# =======================================================================================
# PERFORMANCE ALERTS
# =======================================================================================

# Average Memory Working Set Alert
resource "azurerm_monitor_metric_alert" "average_memory_working_set" {
  for_each            = local.performance_apps
  name                = "func-avg-memory-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} average memory working set exceeds threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageMemoryWorkingSet"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.average_memory_working_set_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "MemoryPerformance"
  })
}

# Average Response Time Alert (Warning)
resource "azurerm_monitor_metric_alert" "average_response_time" {
  for_each            = local.performance_apps
  name                = "func-response-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} average response time exceeds threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResponseTimePerformance"
  })
}

# Average Response Time Alert (Critical)
resource "azurerm_monitor_metric_alert" "average_response_time_critical" {
  for_each            = local.performance_apps
  name                = "func-response-time-critical-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Critical alert when Function App ${each.value.name} average response time exceeds critical threshold"
  severity            = 0
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResponseTimeCritical"
  })
}

# =======================================================================================
# ERROR ALERTS
# =======================================================================================

# HTTP 5xx Error Alert
resource "azurerm_monitor_metric_alert" "http_5xx_errors" {
  for_each            = local.error_apps
  name                = "func-http-5xx-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} HTTP 5xx errors exceed threshold"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_5xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ServerError"
  })
}

# HTTP 4xx Error Alert
resource "azurerm_monitor_metric_alert" "http_4xx_errors" {
  for_each            = local.error_apps
  name                = "func-http-4xx-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} HTTP 4xx errors exceed threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http4xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_4xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ClientError"
  })
}

# =======================================================================================
# RESOURCE UTILIZATION ALERTS
# =======================================================================================

# Memory Working Set Alert
resource "azurerm_monitor_metric_alert" "memory_working_set" {
  for_each            = local.resource_apps
  name                = "func-memory-working-set-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} memory working set exceeds threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryWorkingSet"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_working_set_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "MemoryUtilization"
  })
}

# IO Read Operations Alert
resource "azurerm_monitor_metric_alert" "io_read_ops" {
  for_each            = local.resource_apps
  name                = "func-io-read-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} IO read operations exceed threshold"
  severity            = 3
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "IoReadOperationsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.io_read_ops_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "IOPerformance"
  })
}

# IO Write Operations Alert
resource "azurerm_monitor_metric_alert" "io_write_ops" {
  for_each            = local.resource_apps
  name                = "func-io-write-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} IO write operations exceed threshold"
  severity            = 3
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "IoWriteOperationsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.io_write_ops_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "IOPerformance"
  })
}

# Private Bytes Alert
resource "azurerm_monitor_metric_alert" "private_bytes" {
  for_each            = local.resource_apps
  name                = "func-private-bytes-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} private bytes exceed threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "PrivateBytes"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.private_bytes_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "MemoryUtilization"
  })
}

# Gen 0 Collections Alert (Windows .NET Function Apps only)
resource "azurerm_monitor_metric_alert" "gen_0_collections" {
  for_each            = local.windows_function_apps
  name                = "func-gen0-gc-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} Gen 0 garbage collections exceed threshold"
  severity            = 3
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Gen0Collections"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.gen_0_collections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "GarbageCollection"
  })
}

# Gen 1 Collections Alert (Windows .NET Function Apps only)
resource "azurerm_monitor_metric_alert" "gen_1_collections" {
  for_each            = local.windows_function_apps
  name                = "func-gen1-gc-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} Gen 1 garbage collections exceed threshold"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Gen1Collections"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.gen_1_collections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "GarbageCollection"
  })
}

# Gen 2 Collections Alert (Windows .NET Function Apps only)
resource "azurerm_monitor_metric_alert" "gen_2_collections" {
  for_each            = local.windows_function_apps
  name                = "func-gen2-gc-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} Gen 2 garbage collections exceed threshold"
  severity            = 1
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Gen2Collections"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.gen_2_collections_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "GarbageCollection"
  })
}

# Total Requests Alert
resource "azurerm_monitor_metric_alert" "total_requests" {
  for_each            = local.function_execution_apps
  name                = "func-total-requests-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Function App ${each.value.name} total requests exceed threshold"
  severity            = 3
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "RequestVolume"
  })
}

# =======================================================================================
# ACTIVITY LOG ALERTS
# =======================================================================================

# Activity Log Alert - Function App Creation
resource "azurerm_monitor_activity_log_alert" "function_app_creation" {
  count               = var.enable_function_app_creation_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "FunctionApp-Creation-Alert-${join("-", concat(var.windows_function_app_names, var.linux_function_app_names))}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Function App is created"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/write"
    category       = "Administrative"
    level          = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResourceCreation"
  })
}

# Activity Log Alert - Function App Deletion
resource "azurerm_monitor_activity_log_alert" "function_app_deletion" {
  count               = var.enable_function_app_deletion_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "FunctionApp-Deletion-Alert-${join("-", concat(var.windows_function_app_names, var.linux_function_app_names))}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Function App is deleted"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/delete"
    category       = "Administrative"
    level          = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResourceDeletion"
  })
}

# Activity Log Alert - Function App Configuration Change
resource "azurerm_monitor_activity_log_alert" "function_app_config_change" {
  count               = var.enable_function_app_config_change_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "FunctionApp-ConfigChange-Alert-${join("-", concat(var.windows_function_app_names, var.linux_function_app_names))}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when Function App configuration is modified"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/write"
    category       = "Administrative"
    level          = "Warning"
    status         = "Succeeded"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ConfigurationChange"
  })
}

# =======================================================================================
# SCHEDULED QUERY RULES (LOG ANALYTICS BASED)
# =======================================================================================

# Scheduled Query Rule - Function App Stopped
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_app_stopped" {
  count                = var.enable_function_stopped_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                 = "FunctionApp-Stopped-Alert-${join("-", concat(var.windows_function_app_names, var.linux_function_app_names))}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_medium
  window_duration      = var.window_duration_medium
  scopes               = local.subscription_scopes
  severity             = 1
  description          = "Alert when Function Apps are stopped unexpectedly"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(15m)
      | where ResourceProvider == "Microsoft.Web"
      | where Resource has "sites"
      | where OperationName == "Microsoft.Web/sites/stop/action"
      | where ActivityStatus == "Succeeded"
      | project TimeGenerated, ResourceGroup, Resource, Caller, OperationName
      | summarize count() by bin(TimeGenerated, 5m), ResourceGroup
    EOT
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  tags = merge(var.tags, {
    alert_type = "FunctionAppStopped"
  })
}

# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: Function Apps - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "functionapps_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? local.all_function_apps : {}
  name               = "functionapp-activity-logs-to-eventhub-${each.key}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Function App operations
  enabled_log {
    category = "FunctionAppLogs"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Function Apps - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "functionapps_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? local.all_function_apps : {}
  name               = "functionapp-security-logs-to-loganalytics-${each.key}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "FunctionAppLogs"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
