# Azure Monitor Resources AMBA Alerts
# This file contains comprehensive monitoring alerts for Azure Monitor resources following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.subscription_ids) > 0 || length(var.log_analytics_workspace_names) > 0 || length(var.application_insights_names) > 0 || length(var.data_collection_rule_names) > 0
  subscription_scopes  = var.subscription_ids != [] ? [for id in var.subscription_ids : "/subscriptions/${id}"] : []
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Log Analytics workspaces
data "azurerm_log_analytics_workspace" "workspaces" {
  for_each            = local.should_create_alerts ? toset(var.log_analytics_workspace_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data source for Application Insights
data "azurerm_application_insights" "app_insights" {
  for_each            = local.should_create_alerts ? toset(var.application_insights_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data source for Data Collection Rules
data "azurerm_monitor_data_collection_rule" "dcr" {
  for_each            = local.should_create_alerts ? toset(var.data_collection_rule_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Locals for conditional alert creation
locals {
  # Filtered resources for different alert categories
  workspace_alerts_enabled    = var.enable_workspace_alerts && local.should_create_alerts ? data.azurerm_log_analytics_workspace.workspaces : {}
  app_insights_alerts_enabled = var.enable_application_insights_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
  dcr_alerts_enabled          = var.enable_data_collection_alerts && local.should_create_alerts ? data.azurerm_monitor_data_collection_rule.dcr : {}
}

# =======================================================================================
# LOG ANALYTICS WORKSPACE ALERTS
# =======================================================================================

# Log Analytics Data Ingestion Alert (Warning)
resource "azurerm_monitor_metric_alert" "workspace_data_ingestion" {
  for_each            = local.workspace_alerts_enabled
  name                = "loganalytics-data-ingestion-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Log Analytics workspace ${each.value.name} daily data ingestion exceeds ${var.workspace_data_ingestion_threshold_gb}GB"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_long
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "BillableDataSizeGB"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.workspace_data_ingestion_threshold_gb
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DataIngestion"
  })
}

# Log Analytics Data Ingestion Alert (Critical)
resource "azurerm_monitor_metric_alert" "workspace_data_ingestion_critical" {
  for_each            = local.workspace_alerts_enabled
  name                = "loganalytics-data-ingestion-critical-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Critical alert when Log Analytics workspace ${each.value.name} daily data ingestion exceeds ${var.workspace_data_ingestion_critical_threshold_gb}GB"
  severity            = 0
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "BillableDataSizeGB"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.workspace_data_ingestion_critical_threshold_gb
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DataIngestionCritical"
  })
}

# Log Analytics Workspace Heartbeat Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workspace_heartbeat" {
  for_each             = local.workspace_alerts_enabled
  name                 = "loganalytics-heartbeat-${each.value.name}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_medium
  window_duration      = var.window_duration_medium
  scopes               = [each.value.id]
  severity             = 1
  description          = "Alert when Log Analytics workspace ${each.value.name} has no heartbeat data"

  criteria {
    query                   = <<-EOT
      Heartbeat
      | where TimeGenerated >= ago(15m)
      | summarize count() by bin(TimeGenerated, 5m)
      | where count_ == 0
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
    alert_type = "WorkspaceHeartbeat"
  })
}

# =======================================================================================
# APPLICATION INSIGHTS ALERTS
# =======================================================================================

# Application Insights Availability Alert
resource "azurerm_monitor_metric_alert" "app_insights_availability" {
  for_each            = local.app_insights_alerts_enabled
  name                = "appinsights-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} availability drops below ${var.app_insights_availability_threshold_percent}%"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.app_insights_availability_threshold_percent
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ApplicationAvailability"
  })
}

# Application Insights Response Time Alert
resource "azurerm_monitor_metric_alert" "app_insights_response_time" {
  for_each            = local.app_insights_alerts_enabled
  name                = "appinsights-response-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} response time exceeds ${var.app_insights_response_time_threshold_ms}ms"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.app_insights_response_time_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResponseTime"
  })
}

# Application Insights Failed Requests Alert
resource "azurerm_monitor_metric_alert" "app_insights_failed_requests" {
  for_each            = local.app_insights_alerts_enabled
  name                = "appinsights-failed-requests-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} failed requests exceed ${var.app_insights_failed_requests_threshold}"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.app_insights_failed_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "FailedRequests"
  })
}

# Application Insights Exception Rate Alert
resource "azurerm_monitor_metric_alert" "app_insights_exceptions" {
  for_each            = local.app_insights_alerts_enabled
  name                = "appinsights-exceptions-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} exceptions exceed ${var.app_insights_exception_rate_threshold} per minute"
  severity            = 2
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.app_insights_exception_rate_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ExceptionRate"
  })
}

# =======================================================================================
# DATA COLLECTION RULES ALERTS (using scheduled queries)
# =======================================================================================

# Data Collection Rule Collection Failure Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "dcr_collection_failure" {
  for_each             = local.dcr_alerts_enabled
  name                 = "dcr-collection-failure-${each.value.name}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_medium
  window_duration      = var.window_duration_medium
  scopes               = local.subscription_scopes
  severity             = 1
  description          = "Alert when Data Collection Rule ${each.value.name} has collection failures"

  criteria {
    query                   = <<-EOT
      DCRLogErrors
      | where TimeGenerated >= ago(30m)
      | where DcrName == "${each.value.name}"
      | summarize ErrorCount = count() by bin(TimeGenerated, 15m)
      | where ErrorCount > 0
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
    alert_type = "DCRCollectionFailure"
  })
}

# =======================================================================================
# AZURE MONITOR SERVICE ALERTS (ACTIVITY LOG BASED)
# =======================================================================================

# Log Analytics Workspace Deletion Alert
resource "azurerm_monitor_activity_log_alert" "workspace_deletion" {
  count               = var.enable_workspace_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-Workspace-Deletion-${join("-", var.log_analytics_workspace_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when a Log Analytics workspace is deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.OperationalInsights"
    resource_type     = "Microsoft.OperationalInsights/workspaces"
    operation_name    = "Microsoft.OperationalInsights/workspaces/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "WorkspaceDeletion"
  })
}

# Application Insights Deletion Alert
resource "azurerm_monitor_activity_log_alert" "app_insights_deletion" {
  count               = var.enable_application_insights_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-AppInsights-Deletion-${join("-", var.application_insights_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when an Application Insights resource is deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/components"
    operation_name    = "Microsoft.Insights/components/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "AppInsightsDeletion"
  })
}

# Data Collection Rule Deletion Alert
resource "azurerm_monitor_activity_log_alert" "dcr_deletion" {
  count               = var.enable_data_collection_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-DCR-Deletion-${join("-", var.data_collection_rule_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when a Data Collection Rule is deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/dataCollectionRules"
    operation_name    = "Microsoft.Insights/dataCollectionRules/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DCRDeletion"
  })
}

# Diagnostic Settings Changes Alert
resource "azurerm_monitor_activity_log_alert" "diagnostic_settings_changes" {
  count               = var.enable_diagnostic_settings_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-DiagnosticSettings-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when diagnostic settings are modified or deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/diagnosticSettings"
    operation_name    = "Microsoft.Insights/diagnosticSettings/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DiagnosticSettingsChanges"
  })
}

# Diagnostic Settings Deletion Alert
resource "azurerm_monitor_activity_log_alert" "diagnostic_settings_deletion" {
  count               = var.enable_diagnostic_settings_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-DiagnosticSettings-Deletion-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when diagnostic settings are deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/diagnosticSettings"
    operation_name    = "Microsoft.Insights/diagnosticSettings/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DiagnosticSettingsDeletion"
  })
}

# Action Group Changes Alert
resource "azurerm_monitor_activity_log_alert" "action_group_changes" {
  count               = var.enable_monitor_service_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-ActionGroup-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when action groups are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/actionGroups"
    operation_name    = "Microsoft.Insights/actionGroups/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ActionGroupChanges"
  })
}

# Action Group Deletion Alert
resource "azurerm_monitor_activity_log_alert" "action_group_deletion" {
  count               = var.enable_monitor_service_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "Monitor-ActionGroup-Deletion-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when action groups are deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/actionGroups"
    operation_name    = "Microsoft.Insights/actionGroups/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ActionGroupDeletion"
  })
}
