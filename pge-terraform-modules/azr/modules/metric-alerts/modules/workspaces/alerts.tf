# Log Analytics Workspace Metric Alerts
# This file contains metric alerts for Azure Log Analytics Workspace monitoring following AMBA best practices

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.workspace_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.workspace_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Log Analytics Workspaces using static names
data "azurerm_log_analytics_workspace" "workspaces" {
  for_each            = toset(var.workspace_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Log Analytics Workspace - Data Collection Heartbeat Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_heartbeat" {
  count                = var.enable_workspace_heartbeat_alert && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-heartbeat-missing-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 2
  description          = "Log Analytics Workspace agents not sending heartbeat data"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Heartbeat
      | where TimeGenerated > ago(15m)
      | summarize LastHeartbeat = max(TimeGenerated) by Computer
      | where LastHeartbeat < ago(10m)
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = var.workspace_heartbeat_threshold
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Availability"
  })
}

# Log Analytics Workspace - Query Performance Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_query_performance" {
  count                = var.enable_workspace_query_performance_alert && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-query-performance-slow-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT15M"
  window_duration      = "PT30M"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 3
  description          = "Log Analytics Workspace queries are running slowly"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Operation
      | where TimeGenerated > ago(30m)
      | where OperationCategory == "Query"
      | where OperationStatus == "Success"
      | extend QueryDuration = todouble(OperationKey)
      | where QueryDuration > ${var.workspace_query_performance_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 5
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Log Analytics Workspace - Data Retention Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_data_retention" {
  count                = var.enable_workspace_data_retention_alert && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-data-retention-expiring-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "P1D"
  window_duration      = "P1D"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 3
  description          = "Log Analytics Workspace data approaching retention limit"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Usage
      | where TimeGenerated > ago(1d)
      | where IsBillable == true
      | extend RetentionDays = ${var.workspace_retention_days}
      | extend DaysFromRetention = RetentionDays - datetime_diff('day', now(), TimeGenerated)
      | where DaysFromRetention <= ${var.workspace_retention_warning_days}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Maintenance"
  })
}

# Log Analytics Workspace - High Error Rate Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_error_rate" {
  count                = var.enable_workspace_error_rate_alert && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-error-rate-high-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT15M"
  window_duration      = "PT30M"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 2
  description          = "High error rate detected in Log Analytics Workspace"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Operation
      | where TimeGenerated > ago(30m)
      | where OperationStatus == "Failed"
      | summarize ErrorCount = count(), TotalCount = countif(OperationStatus in ("Success", "Failed"))
      | extend ErrorRate = (ErrorCount * 100.0) / TotalCount
      | where ErrorRate > ${var.workspace_error_rate_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Error"
  })
}

# Log Analytics Workspace - Agent Connection Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_agent_connection" {
  count                = var.enable_workspace_agent_connection_alert && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-agent-connection-lost-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT15M"
  window_duration      = "PT1H"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 3
  description          = "Log Analytics agents experiencing connection issues"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Operation
      | where TimeGenerated > ago(1h)
      | where OperationCategory == "Data Collection"
      | where Detail contains "connection" or Detail contains "timeout"
      | summarize ConnectionIssues = count() by Computer
      | where ConnectionIssues > ${var.workspace_agent_connection_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Connectivity"
  })
}

# Log Analytics Workspace - Custom Table Data Ingestion Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_custom_table_ingestion" {
  count                = var.enable_workspace_custom_table_alert && length(var.workspace_custom_tables) > 0 && length(var.workspace_names) > 0 ? 1 : 0
  name                 = "workspace-custom-table-ingestion-low-${join("-", var.workspace_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT30M"
  window_duration      = "PT2H"
  scopes               = [for workspace in data.azurerm_log_analytics_workspace.workspaces : workspace.id]
  severity             = 3
  description          = "Custom table data ingestion is below expected threshold"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Usage
      | where TimeGenerated > ago(2h)
      | where DataType in (${join(",", [for table in var.workspace_custom_tables : "'${table}'"])})
      | summarize DataVolume = sum(Quantity) by DataType
      | where DataVolume < ${var.workspace_custom_table_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "Data Quality"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Log Analytics Workspace Logs to Event Hub for external SIEM integration
resource "azurerm_monitor_diagnostic_setting" "workspace_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.workspace_names) : []

  name                           = "send-workspace-logs-to-eventhub"
  target_resource_id             = data.azurerm_log_analytics_workspace.workspaces[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Log Analytics Workspace Log Categories
  enabled_log {
    category = "Audit"
  }

  # Metrics disabled for Event Hub destination
  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    ignore_changes = [
      eventhub_name,
      eventhub_authorization_rule_id,
    ]
  }
}

# Send Log Analytics Workspace Security Logs to Log Analytics Workspace for analysis
resource "azurerm_monitor_diagnostic_setting" "workspace_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.workspace_names) : []

  name                       = "send-workspace-logs-to-loganalytics"
  target_resource_id         = data.azurerm_log_analytics_workspace.workspaces[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Log Analytics Workspace Log Categories
  enabled_log {
    category = "Audit"
  }

  # Metrics for Log Analytics
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      log_analytics_workspace_id,
    ]
  }
}
