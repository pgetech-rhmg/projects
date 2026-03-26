# AMBA Alerts for Azure App Service Environment (ASE)
# This file contains comprehensive monitoring alerts for Azure App Service Environment

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for App Service Environments using static names
data "azurerm_app_service_environment_v3" "ases" {
  for_each            = toset(var.ase_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != ""
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != ""
}

# ASE CPU Percentage Alert
resource "azurerm_monitor_metric_alert" "ase_cpu_percentage" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-cpu-percentage-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE CPU percentage exceeds ${var.ase_cpu_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_cpu_percentage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-cpu-percentage"
  })
}

# ASE Memory Percentage Alert
resource "azurerm_monitor_metric_alert" "ase_memory_percentage" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-memory-percentage-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE memory percentage exceeds ${var.ase_memory_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_memory_percentage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-memory-percentage"
  })
}

# ASE Large App Service Plan Instances Alert
resource "azurerm_monitor_metric_alert" "ase_large_app_service_plan_instances" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-large-app-service-plan-instances-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE large App Service plan instances exceed ${var.ase_large_app_service_plan_instances_threshold}"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "LargeAppServicePlanInstances"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_large_app_service_plan_instances_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-large-app-service-plan-instances"
  })
}

# ASE Medium App Service Plan Instances Alert
resource "azurerm_monitor_metric_alert" "ase_medium_app_service_plan_instances" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-medium-app-service-plan-instances-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE medium App Service plan instances exceed ${var.ase_medium_app_service_plan_instances_threshold}"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "MediumAppServicePlanInstances"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_medium_app_service_plan_instances_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-medium-app-service-plan-instances"
  })
}

# ASE Small App Service Plan Instances Alert
resource "azurerm_monitor_metric_alert" "ase_small_app_service_plan_instances" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-small-app-service-plan-instances-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE small App Service plan instances exceed ${var.ase_small_app_service_plan_instances_threshold}"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "SmallAppServicePlanInstances"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_small_app_service_plan_instances_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-small-app-service-plan-instances"
  })
}

# ASE Total Front End Instances Alert
resource "azurerm_monitor_metric_alert" "ase_total_front_end_instances" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-total-front-end-instances-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE total front end instances exceed ${var.ase_total_front_end_instances_threshold}"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "TotalFrontEnds"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_total_front_end_instances_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-total-front-end-instances"
  })
}

# ASE Data In Alert
resource "azurerm_monitor_metric_alert" "ase_data_in" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-data-in-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE data in exceeds ${var.ase_data_in_threshold} bytes"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "BytesReceived"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_data_in_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-data-in"
  })
}

# ASE Data Out Alert
resource "azurerm_monitor_metric_alert" "ase_data_out" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-data-out-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE data out exceeds ${var.ase_data_out_threshold} bytes"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "BytesSent"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_data_out_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-data-out"
  })
}

# ASE Average Response Time Alert
resource "azurerm_monitor_metric_alert" "ase_average_response_time" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-average-response-time-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE average response time exceeds ${var.ase_average_response_time_threshold} seconds"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_average_response_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-average-response-time"
  })
}

# ASE HTTP Queue Length Alert
resource "azurerm_monitor_metric_alert" "ase_http_queue_length" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-queue-length-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP queue length exceeds ${var.ase_http_queue_length_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "HttpQueueLength"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.ase_http_queue_length_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-queue-length"
  })
}

# ASE HTTP 4xx Responses Alert
resource "azurerm_monitor_metric_alert" "ase_http_4xx" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-4xx-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP 4xx responses exceed ${var.ase_http_4xx_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Http4xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_http_4xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-4xx"
  })
}

# ASE HTTP 5xx Responses Alert
resource "azurerm_monitor_metric_alert" "ase_http_5xx" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-5xx-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP 5xx responses exceed ${var.ase_http_5xx_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_http_5xx_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-5xx"
  })
}

# ASE HTTP 401 Responses Alert
resource "azurerm_monitor_metric_alert" "ase_http_401" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-401-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP 401 responses exceed ${var.ase_http_401_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Http401"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_http_401_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-401"
  })
}

# ASE HTTP 403 Responses Alert
resource "azurerm_monitor_metric_alert" "ase_http_403" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-403-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP 403 responses exceed ${var.ase_http_403_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Http403"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_http_403_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-403"
  })
}

# ASE HTTP 404 Responses Alert
resource "azurerm_monitor_metric_alert" "ase_http_404" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-http-404-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE HTTP 404 responses exceed ${var.ase_http_404_threshold}"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Http404"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_http_404_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-http-404"
  })
}

# ASE Total Requests Alert
resource "azurerm_monitor_metric_alert" "ase_total_requests" {
  for_each            = data.azurerm_app_service_environment_v3.ases
  name                = "ase-total-requests-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when ASE total requests exceed ${var.ase_total_requests_threshold} (high volume detection)"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/hostingEnvironments"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.ase_total_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-total-requests"
  })
}

# Activity Log Alert - ASE Configuration Changes
resource "azurerm_monitor_activity_log_alert" "ase_configuration_change" {
  count               = length(var.ase_names) > 0 ? 1 : 0
  name                = "ase-configuration-change"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for ase in data.azurerm_app_service_environment_v3.ases : ase.id]
  description         = "Alert when App Service Environment configuration is changed"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Web"
    resource_type     = "Microsoft.Web/hostingEnvironments"
    operation_name    = "Microsoft.Web/hostingEnvironments/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-configuration-change"
  })
}

# Activity Log Alert - ASE Deletion
resource "azurerm_monitor_activity_log_alert" "ase_deletion" {
  count               = length(var.ase_names) > 0 ? 1 : 0
  name                = "ase-deletion"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for ase in data.azurerm_app_service_environment_v3.ases : ase.id]
  description         = "Alert when App Service Environment is deleted"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Web"
    resource_type     = "Microsoft.Web/hostingEnvironments"
    operation_name    = "Microsoft.Web/hostingEnvironments/delete"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "ase-deletion"
  })
}

# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: ASE - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "ase_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? data.azurerm_app_service_environment_v3.ases : {}
  name               = "ase-activity-logs-to-eventhub-${each.value.name}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - ASE operations and telemetry
  enabled_log {
    category = "AppServiceEnvironmentPlatformLogs"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: ASE - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "ase_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? data.azurerm_app_service_environment_v3.ases : {}
  name               = "ase-security-logs-to-loganalytics-${each.value.name}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "AppServiceEnvironmentPlatformLogs"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
