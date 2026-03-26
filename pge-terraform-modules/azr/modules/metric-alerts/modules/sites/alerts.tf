# AMBA Alerts for Azure App Service Sites
# This file contains comprehensive monitoring alerts for App Service sites

# Validation check for site names
locals {
  site_names_validation = length(var.windows_site_names) + length(var.linux_site_names) > 0 ? true : tobool("At least one of windows_site_names or linux_site_names must be provided")
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Windows App Service sites
data "azurerm_windows_web_app" "windows_sites" {
  for_each            = toset(var.windows_site_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data source for Linux App Service sites
data "azurerm_linux_web_app" "linux_sites" {
  for_each            = toset(var.linux_site_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Combine Windows and Linux sites for alerting
locals {
  all_sites = merge(
    { for k, v in data.azurerm_windows_web_app.windows_sites : k => v },
    { for k, v in data.azurerm_linux_web_app.linux_sites : k => v }
  )

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && (length(var.windows_site_names) > 0 || length(var.linux_site_names) > 0)
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && (length(var.windows_site_names) > 0 || length(var.linux_site_names) > 0)
}

# Response Time Alert (Warning)
resource "azurerm_monitor_metric_alert" "site_response_time" {
  for_each            = local.all_sites
  name                = "site-response-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site response time exceeds ${var.response_time_threshold} seconds"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-response-time"
  })
}

# Response Time Alert (Critical)
resource "azurerm_monitor_metric_alert" "site_response_time_critical" {
  for_each            = local.all_sites
  name                = "site-response-time-critical-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Critical alert when App Service site response time exceeds ${var.response_time_critical_threshold} seconds"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_critical_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-response-time-critical"
  })
}

# HTTP 4xx Error Alert
resource "azurerm_monitor_metric_alert" "site_http_4xx" {
  for_each            = local.all_sites
  name                = "site-http-4xx-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site HTTP 4xx errors exceed ${var.http_4xx_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http4xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_4xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-http-4xx"
  })
}

# HTTP 5xx Error Alert
resource "azurerm_monitor_metric_alert" "site_http_5xx" {
  for_each            = local.all_sites
  name                = "site-http-5xx-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site HTTP 5xx errors exceed ${var.http_5xx_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_5xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-http-5xx"
  })
}

# Request Rate Alert
resource "azurerm_monitor_metric_alert" "site_request_rate" {
  for_each            = local.all_sites
  name                = "site-request-rate-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site request rate exceeds ${var.request_rate_threshold} requests"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.request_rate_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-request-rate"
  })
}

# CPU Time Alert
resource "azurerm_monitor_metric_alert" "site_cpu_time" {
  for_each            = local.all_sites
  name                = "site-cpu-time-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site CPU time exceeds ${var.cpu_time_threshold} seconds"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuTime"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cpu_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-cpu-time"
  })
}

# Availability Alert
resource "azurerm_monitor_metric_alert" "site_availability" {
  for_each            = local.all_sites
  name                = "site-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site availability drops below ${var.availability_threshold}%"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-availability"
  })
}

# IO Read Operations Alert
resource "azurerm_monitor_metric_alert" "site_io_read_ops" {
  for_each            = local.all_sites
  name                = "site-io-read-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site IO read operations are high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "IoReadOperationsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 100
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-io-read-ops"
  })
}

# IO Write Operations Alert
resource "azurerm_monitor_metric_alert" "site_io_write_ops" {
  for_each            = local.all_sites
  name                = "site-io-write-ops-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service site IO write operations are high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "IoWriteOperationsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 100
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "site-io-write-ops"
  })
}

# Diagnostic Settings to Event Hub (for activity logs) - Windows Sites
resource "azurerm_monitor_diagnostic_setting" "windows_site_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.windows_site_names) : []
  name                           = "site-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_windows_web_app.windows_sites[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs) - Windows Sites
resource "azurerm_monitor_diagnostic_setting" "windows_site_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.windows_site_names) : []
  name                       = "site-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_windows_web_app.windows_sites[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings to Event Hub (for activity logs) - Linux Sites
resource "azurerm_monitor_diagnostic_setting" "linux_site_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.linux_site_names) : []
  name                           = "site-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_linux_web_app.linux_sites[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# Diagnostic Settings to Log Analytics (for security logs) - Linux Sites
resource "azurerm_monitor_diagnostic_setting" "linux_site_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.linux_site_names) : []
  name                       = "site-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_linux_web_app.linux_sites[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
