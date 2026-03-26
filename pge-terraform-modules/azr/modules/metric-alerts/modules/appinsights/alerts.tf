# Azure Application Insights AMBA Alerts
# This file contains comprehensive monitoring alerts for Application Insights following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.application_insights_names) > 0 || length(var.subscription_ids) > 0
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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != ""
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != ""
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Application Insights
data "azurerm_application_insights" "app_insights" {
  for_each            = local.should_create_alerts ? toset(var.application_insights_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Locals for conditional alert creation
locals {
  # Filtered resources for different alert categories
  availability_alerts_enabled = var.enable_availability_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
  performance_alerts_enabled  = var.enable_performance_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
  error_alerts_enabled        = var.enable_error_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
  usage_alerts_enabled        = var.enable_usage_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
  dependency_alerts_enabled   = var.enable_dependency_alerts && local.should_create_alerts ? data.azurerm_application_insights.app_insights : {}
}

# =======================================================================================
# AVAILABILITY ALERTS
# =======================================================================================

# Application Availability Alert
resource "azurerm_monitor_metric_alert" "availability" {
  for_each            = local.availability_alerts_enabled
  name                = "appinsights-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} availability drops below ${var.availability_threshold_percent}%"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold_percent
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ApplicationAvailability"
  })
}

# =======================================================================================
# PERFORMANCE ALERTS
# =======================================================================================

# Response Time Alert
resource "azurerm_monitor_metric_alert" "response_time" {
  for_each            = local.performance_alerts_enabled
  name                = "appinsights-response-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} average response time exceeds ${var.response_time_threshold_ms}ms"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResponseTime"
  })
}

# Server Response Time Alert
resource "azurerm_monitor_metric_alert" "server_response_time" {
  for_each            = local.performance_alerts_enabled
  name                = "appinsights-server-response-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} server response time exceeds ${var.server_response_time_threshold_ms}ms"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "performanceCounters/requestExecutionTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.server_response_time_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ServerResponseTime"
  })
}

# Dependency Duration Alert
resource "azurerm_monitor_metric_alert" "dependency_duration" {
  for_each            = local.dependency_alerts_enabled
  name                = "appinsights-dependency-duration-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} dependency duration exceeds ${var.dependency_duration_threshold_ms}ms"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "dependencies/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.dependency_duration_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DependencyDuration"
  })
}

# Page View Load Time Alert
resource "azurerm_monitor_metric_alert" "page_view_load_time" {
  for_each            = local.performance_alerts_enabled
  name                = "appinsights-page-load-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} page view load time exceeds ${var.page_view_load_time_threshold_ms}ms"
  severity            = 3
  frequency           = var.evaluation_frequency_low
  window_size         = var.window_duration_long
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "browserTimings/totalDuration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.page_view_load_time_threshold_ms
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "PageLoadTime"
  })
}

# =======================================================================================
# ERROR ALERTS
# =======================================================================================

# Exception Rate Alert
resource "azurerm_monitor_metric_alert" "exception_rate" {
  for_each            = local.error_alerts_enabled
  name                = "appinsights-exceptions-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} exceptions exceed ${var.exception_rate_threshold} per evaluation period"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.exception_rate_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ExceptionRate"
  })
}

# Failed Requests Alert
resource "azurerm_monitor_metric_alert" "failed_requests" {
  for_each            = local.error_alerts_enabled
  name                = "appinsights-failed-requests-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} failed requests exceed ${var.failed_requests_threshold}"
  severity            = 1
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.failed_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "FailedRequests"
  })
}

# Dependency Failure Rate Alert
resource "azurerm_monitor_metric_alert" "dependency_failure_rate" {
  for_each            = local.dependency_alerts_enabled
  name                = "appinsights-dependency-failures-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} dependency failures exceed ${var.dependency_failure_rate_threshold}"
  severity            = 2
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "dependencies/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.dependency_failure_rate_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DependencyFailures"
  })
}

# =======================================================================================
# USAGE ALERTS
# =======================================================================================

# Request Rate Alert
resource "azurerm_monitor_metric_alert" "request_rate" {
  for_each            = local.usage_alerts_enabled
  name                = "appinsights-request-rate-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} request rate exceeds ${var.request_rate_threshold} requests per second"
  severity            = 3
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/rate"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.request_rate_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "RequestRate"
  })
}

# Page View Count Alert
resource "azurerm_monitor_metric_alert" "page_view_count" {
  for_each            = local.usage_alerts_enabled
  name                = "appinsights-page-views-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Application Insights ${each.value.name} has unusual page view patterns"
  severity            = 3
  frequency           = var.evaluation_frequency_low
  window_size         = var.window_duration_long
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "pageViews/count"
    aggregation      = "Count"
    operator         = "LessThan"
    threshold        = 1 # Alert when no page views (unusual pattern)
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "PageViewCount"
  })
}

# =======================================================================================
# ACTIVITY LOG ALERTS
# =======================================================================================

# Application Insights Deletion Alert
resource "azurerm_monitor_activity_log_alert" "app_insights_deletion" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AppInsights-Deletion-${join("-", var.application_insights_names)}"
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

# Application Insights Configuration Changes Alert
resource "azurerm_monitor_activity_log_alert" "app_insights_config_change" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AppInsights-ConfigChange-${join("-", var.application_insights_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Application Insights configuration is modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/components"
    operation_name    = "Microsoft.Insights/components/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "AppInsightsConfigChange"
  })
}

# Application Insights API Key Changes Alert
resource "azurerm_monitor_activity_log_alert" "app_insights_api_key_change" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AppInsights-APIKeyChange-${join("-", var.application_insights_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Application Insights API keys are created, modified, or deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Insights"
    resource_type     = "Microsoft.Insights/components/ApiKeys"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "AppInsightsAPIKeyChange"
  })
}

# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: Application Insights - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "appinsights_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? data.azurerm_application_insights.app_insights : {}
  name               = "appinsights-activity-logs-to-eventhub-${each.value.name}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Administrative operations and general telemetry
  enabled_log {
    category = "AppTraces"
  }

  enabled_log {
    category = "AppMetrics"
  }

  enabled_log {
    category = "AppAvailabilityResults"
  }

  enabled_log {
    category = "AppPerformanceCounters"
  }

  enabled_log {
    category = "AppEvents"
  }

  enabled_log {
    category = "AppDependencies"
  }

  enabled_log {
    category = "AppRequests"
  }

  enabled_log {
    category = "AppSystemEvents"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Application Insights - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "appinsights_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? data.azurerm_application_insights.app_insights : {}
  name               = "appinsights-security-logs-to-loganalytics-${each.value.name}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "AppExceptions"
  }

  enabled_log {
    category = "AppRequests"
  }

  enabled_log {
    category = "AppDependencies"
  }

  enabled_log {
    category = "AppSystemEvents"
  }

  enabled_log {
    category = "AppTraces"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
