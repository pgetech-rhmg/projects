# Azure Front Door AMBA Alerts
# This file contains comprehensive monitoring alerts for Azure Front Door following AMBA best practices

# Data sources for existing resources
data "azurerm_client_config" "current" {}

data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Local values for resource identification
locals {
  # Support both Front Door types with smart defaults
  # Create resource configurations for both Classic and Standard/Premium Front Door
  classic_config = {
    resource_provider     = "Microsoft.Network"
    resource_type         = "frontDoors"
    metric_namespace      = "Microsoft.Network/frontDoors"
    backend_health_metric = "BackendHealthPercentage"
    request_count_metric  = "RequestCount"
    response_time_metric  = "TotalLatency"
    waf_metric            = "WebApplicationFirewallRequestCount"
  }

  standard_config = {
    resource_provider     = "Microsoft.Cdn"
    resource_type         = "profiles"
    metric_namespace      = "Microsoft.Cdn/profiles"
    backend_health_metric = "OriginHealthPercentage"
    request_count_metric  = "RequestCount"
    response_time_metric  = "TotalLatency"
    waf_metric            = "WebApplicationFirewallRequestCount"
  }

  # Select configuration based on Front Door type
  selected_config = var.front_door_type == "classic" ? local.classic_config : local.standard_config

  # Determine resource provider and type based on Front Door type  
  resource_provider = local.selected_config.resource_provider
  resource_type     = local.selected_config.resource_type
  metric_namespace  = local.selected_config.metric_namespace

  # Use current subscription if subscription_ids is empty
  effective_subscription_ids = length(var.subscription_ids) > 0 ? var.subscription_ids : [data.azurerm_client_config.current.subscription_id]

  # Create individual resource scopes for each Front Door (no multi-resource support for CDN profiles)
  front_door_resources = flatten([
    for sub_id in local.effective_subscription_ids : [
      for fd_name in var.front_door_names : {
        name  = fd_name
        scope = "/subscriptions/${sub_id}/resourceGroups/${var.resource_group_name}/providers/${local.resource_provider}/${local.resource_type}/${fd_name}"
      }
    ]
  ])

  # Subscription-level scopes for activity log alerts
  subscription_scopes = [for sub_id in local.effective_subscription_ids : "/subscriptions/${sub_id}"]

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && length(var.front_door_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.front_door_names) > 0

  # Common tags for all Front Door alerts
  common_tags = merge(var.tags, {
    service_type = "FrontDoor"
    alert_source = "AMBA"
  })

  # Conditional resource creation flags
  performance_alerts_enabled  = var.enable_performance_alerts && length(var.front_door_names) > 0
  availability_alerts_enabled = var.enable_availability_alerts && length(var.front_door_names) > 0
  security_alerts_enabled     = var.enable_security_alerts && length(var.front_door_names) > 0
  cost_alerts_enabled         = var.enable_cost_alerts && length(var.front_door_names) > 0
}

# ==========================================
# PERFORMANCE MONITORING ALERTS
# ==========================================

# High Response Time Alert
resource "azurerm_monitor_metric_alert" "front_door_high_response_time" {
  for_each            = local.performance_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-High-Response-Time-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when Front Door ${each.key} response time is consistently high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Performance"
    metric     = "ResponseTime"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = local.selected_config.response_time_metric
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# Backend Health Degradation Alert
resource "azurerm_monitor_metric_alert" "front_door_backend_health" {
  for_each            = local.performance_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-Backend-Health-Degraded-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when Front Door ${each.key} backend health drops below threshold"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Performance"
    metric     = "BackendHealth"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = local.selected_config.backend_health_metric
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.backend_health_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# High Request Count Alert
resource "azurerm_monitor_metric_alert" "front_door_high_request_count" {
  for_each            = local.performance_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-High-Request-Count-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when Front Door ${each.key} receives unusually high number of requests"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Performance"
    metric     = "RequestCount"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = local.selected_config.request_count_metric
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.request_count_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# ==========================================
# AVAILABILITY MONITORING ALERTS
# ==========================================

# High Error Rate Alert
resource "azurerm_monitor_metric_alert" "front_door_high_error_rate" {
  for_each            = local.availability_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-High-Error-Rate-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when Front Door ${each.key} error rate exceeds threshold"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Availability"
    metric     = "ErrorRate"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = "ResponseSize"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.error_rate_threshold

    dimension {
      name     = "HttpStatusGroup"
      operator = "Include"
      values   = ["4xx", "5xx"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# Low Availability Alert
resource "azurerm_monitor_metric_alert" "front_door_low_availability" {
  for_each            = local.availability_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-Low-Availability-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when Front Door ${each.key} availability drops below threshold"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Availability"
    metric     = "Availability"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = local.selected_config.backend_health_metric
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# ==========================================
# SECURITY MONITORING ALERTS
# ==========================================

# WAF High Blocked Requests Alert
resource "azurerm_monitor_metric_alert" "front_door_waf_blocked_requests" {
  for_each            = local.security_alerts_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name                = "FrontDoor-WAF-High-Blocked-Requests-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope]
  description         = "Alert when WAF blocks unusually high number of requests on Front Door ${each.key}"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  tags = merge(local.common_tags, {
    alert_type = "Security"
    metric     = "WAFBlockedRequests"
  })

  criteria {
    metric_namespace = local.metric_namespace
    metric_name      = local.selected_config.waf_metric
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.waf_blocked_requests_threshold

    dimension {
      name     = "Action"
      operator = "Include"
      values   = ["Block"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# ==========================================
# COST MONITORING ALERTS
# ==========================================

# High Bandwidth Usage Alert (using scheduled query rule for cost analysis)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "front_door_high_bandwidth" {
  count                            = local.cost_alerts_enabled ? 1 : 0
  name                             = "FrontDoor-High-Bandwidth-Usage-${join("-", var.front_door_names)}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = "P1D"
  window_duration                  = "P1D"
  scopes                           = local.subscription_scopes
  severity                         = 2
  description                      = "Alert when Front Door bandwidth usage is high"
  enabled                          = true
  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false

  tags = merge(local.common_tags, {
    alert_type = "Cost"
    metric     = "BandwidthUsage"
  })

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProvider == "Microsoft.Network"
      | where ResourceId contains "frontDoors"
      | where OperationNameValue contains "Microsoft.Network/frontdoors"
      | where ActivityStatusValue == "Success"
      | summarize BandwidthActivity = count() by bin(TimeGenerated, 1h)
      | where BandwidthActivity > 10
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
}

# High Request Count Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "front_door_high_request_cost" {
  count                            = local.cost_alerts_enabled ? 1 : 0
  name                             = "FrontDoor-High-Request-Cost-${join("-", var.front_door_names)}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = "P1D"
  window_duration                  = "P1D"
  scopes                           = local.subscription_scopes
  severity                         = 2
  description                      = "Alert when Front Door request count indicates high costs"
  enabled                          = true
  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false

  tags = merge(local.common_tags, {
    alert_type = "Cost"
    metric     = "RequestCost"
  })

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProvider == "Microsoft.Network"
      | where ResourceId contains "frontDoors"
      | where OperationNameValue contains "request"
      | where ActivityStatusValue == "Success"
      | summarize RequestActivity = count() by bin(TimeGenerated, 1h)
      | where RequestActivity > 100
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
}

# ==========================================
# ACTIVITY LOG ALERTS
# ==========================================

# Front Door Configuration Changes Alert
resource "azurerm_monitor_activity_log_alert" "front_door_config_changes" {
  count               = length(var.front_door_names) > 0 ? 1 : 0
  name                = "FrontDoor-Configuration-Changes-${join("-", var.front_door_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Front Door configuration is modified"
  enabled             = true
  location            = "global"

  tags = merge(local.common_tags, {
    alert_type = "Administrative"
    operation  = "ConfigurationChange"
  })

  criteria {
    category          = "Administrative"
    operation_name    = "Microsoft.Network/frontDoors/write"
    resource_provider = "Microsoft.Network"
    resource_type     = "Microsoft.Network/frontDoors"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# Front Door Deletion Alert
resource "azurerm_monitor_activity_log_alert" "front_door_deletion" {
  count               = length(var.front_door_names) > 0 ? 1 : 0
  name                = "FrontDoor-Resource-Deletion-${join("-", var.front_door_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Front Door resource is deleted"
  enabled             = true
  location            = "global"

  tags = merge(local.common_tags, {
    alert_type = "Administrative"
    operation  = "ResourceDeletion"
  })

  criteria {
    category          = "Administrative"
    operation_name    = "Microsoft.Network/frontDoors/delete"
    resource_provider = "Microsoft.Network"
    resource_type     = "Microsoft.Network/frontDoors"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# Front Door Backend Pool Changes Alert
resource "azurerm_monitor_activity_log_alert" "front_door_backend_changes" {
  count               = length(var.front_door_names) > 0 ? 1 : 0
  name                = "FrontDoor-Backend-Pool-Changes-${join("-", var.front_door_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Front Door backend pool configuration changes"
  enabled             = true
  location            = "global"

  tags = merge(local.common_tags, {
    alert_type = "Administrative"
    operation  = "BackendPoolChange"
  })

  criteria {
    category          = "Administrative"
    operation_name    = "Microsoft.Network/frontDoors/backendPools/write"
    resource_provider = "Microsoft.Network"
    resource_type     = "Microsoft.Network/frontDoors/backendPools"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }
}

# ==========================================
# ADVANCED MONITORING ALERTS
# ==========================================

# Front Door Origin Health Degradation
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "front_door_origin_health_degradation" {
  count                            = local.availability_alerts_enabled ? 1 : 0
  name                             = "FrontDoor-Origin-Health-Degradation-${join("-", var.front_door_names)}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = "PT5M"
  window_duration                  = "PT15M"
  scopes                           = local.subscription_scopes
  severity                         = 1
  description                      = "Alert when Front Door origin health shows degradation patterns"
  enabled                          = true
  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false

  tags = merge(local.common_tags, {
    alert_type = "AdvancedAvailability"
    metric     = "OriginHealthDegradation"
  })

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(15m)
      | where ResourceProvider == "Microsoft.Network"
      | where ResourceId contains "frontDoors"
      | where OperationNameValue contains "health"
      | where ActivityStatusValue == "Failed"
      | summarize HealthIssues = count() by bin(TimeGenerated, 5m), ResourceId
      | where HealthIssues > 0
      | summarize UnhealthyPeriods = count() by ResourceId
      | where UnhealthyPeriods >= 2
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
}

# Front Door SSL Certificate Expiration Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "front_door_ssl_expiration" {
  count                            = local.security_alerts_enabled ? 1 : 0
  name                             = "FrontDoor-SSL-Certificate-Expiration-${join("-", var.front_door_names)}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = "P1D"
  window_duration                  = "P1D"
  scopes                           = local.subscription_scopes
  severity                         = 2
  description                      = "Alert when Front Door SSL certificates are approaching expiration"
  enabled                          = true
  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false

  tags = merge(local.common_tags, {
    alert_type = "Security"
    metric     = "SSLCertificateExpiration"
  })

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProvider == "Microsoft.Network"
      | where ResourceId contains "frontDoors"
      | where OperationNameValue contains "certificate"
      | where ActivityStatusValue == "Success"
      | summarize CertificateOperations = count() by ResourceId
      | where CertificateOperations > 0
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
}
# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: Front Door - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "frontdoor_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name               = "frontdoor-activity-logs-to-eventhub-${each.key}"
  target_resource_id = each.value.scope

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Front Door operations
  # Note: Log categories differ between Classic Front Door and Standard/Premium
  # Classic Front Door (Microsoft.Network/frontDoors)
  dynamic "enabled_log" {
    for_each = var.front_door_type == "classic" ? ["FrontdoorAccessLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "classic" ? ["FrontdoorWebApplicationFirewallLog"] : []
    content {
      category = enabled_log.value
    }
  }

  # Standard/Premium Front Door (Microsoft.Cdn/profiles)
  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorAccessLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorHealthProbeLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorWebApplicationFirewallLog"] : []
    content {
      category = enabled_log.value
    }
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Front Door - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "frontdoor_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? { for fd in local.front_door_resources : fd.name => fd } : {}
  name               = "frontdoor-security-logs-to-loganalytics-${each.key}"
  target_resource_id = each.value.scope

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  # Classic Front Door (Microsoft.Network/frontDoors)
  dynamic "enabled_log" {
    for_each = var.front_door_type == "classic" ? ["FrontdoorAccessLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "classic" ? ["FrontdoorWebApplicationFirewallLog"] : []
    content {
      category = enabled_log.value
    }
  }

  # Standard/Premium Front Door (Microsoft.Cdn/profiles)
  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorAccessLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorHealthProbeLog"] : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.front_door_type == "standard" ? ["FrontDoorWebApplicationFirewallLog"] : []
    content {
      category = enabled_log.value
    }
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
