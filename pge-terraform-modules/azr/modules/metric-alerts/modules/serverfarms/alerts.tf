# AMBA Alerts for Azure App Service Serverfarms

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.serverfarm_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.serverfarm_names) > 0
}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for serverfarms using static names
data "azurerm_service_plan" "serverfarms" {
  for_each            = toset(var.serverfarm_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# CPU Percentage Alert
resource "azurerm_monitor_metric_alert" "serverfarm_cpu_percentage" {
  for_each            = data.azurerm_service_plan.serverfarms
  name                = "serverfarm-cpu-percentage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service serverfarm CPU percentage exceeds ${var.cpu_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_percentage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "serverfarm-cpu-percentage"
  })
}

# Memory Percentage Alert
resource "azurerm_monitor_metric_alert" "serverfarm_memory_percentage" {
  for_each            = data.azurerm_service_plan.serverfarms
  name                = "serverfarm-memory-percentage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service serverfarm memory percentage exceeds ${var.memory_percentage_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_percentage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "serverfarm-memory-percentage"
  })
}

# HTTP Queue Length Alert
resource "azurerm_monitor_metric_alert" "serverfarm_http_queue_length" {
  for_each            = data.azurerm_service_plan.serverfarms
  name                = "serverfarm-http-queue-length-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service serverfarm HTTP queue length exceeds ${var.http_queue_length_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "HttpQueueLength"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.http_queue_length_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "serverfarm-http-queue-length"
  })
}

# Disk Queue Length Alert
resource "azurerm_monitor_metric_alert" "serverfarm_disk_queue_length" {
  for_each            = data.azurerm_service_plan.serverfarms
  name                = "serverfarm-disk-queue-length-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when App Service serverfarm disk queue length exceeds ${var.disk_queue_length_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "DiskQueueLength"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_queue_length_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "serverfarm-http-queue-length"
  })
}

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "serverfarm_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.serverfarm_names) : []
  name                           = "serverfarm-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_service_plan.serverfarms[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "serverfarm_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.serverfarm_names) : []
  name                       = "serverfarm-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_service_plan.serverfarms[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
