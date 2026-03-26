# Azure Traffic Manager AMBA Alerts
# This file contains metric and activity log alerts for Azure Traffic Manager monitoring following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation and cross-subscription support
locals {
  should_create_alerts = length(var.traffic_manager_profile_names) > 0
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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.traffic_manager_profile_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.traffic_manager_profile_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Traffic Manager profiles using static names
data "azurerm_traffic_manager_profile" "traffic_manager_profiles" {
  for_each            = local.should_create_alerts ? toset(var.traffic_manager_profile_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# =======================================================================================
# METRIC ALERTS
# =======================================================================================

# Traffic Manager - Endpoint Health Alert
resource "azurerm_monitor_metric_alert" "endpoint_health" {
  for_each            = data.azurerm_traffic_manager_profile.traffic_manager_profiles
  name                = "TrafficManager-endpoint-health-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Traffic Manager ${each.value.name} has unhealthy endpoints"
  severity            = 1
  frequency           = var.evaluation_frequency_medium
  window_size         = var.window_duration_medium
  enabled             = var.enable_endpoint_health_alert

  criteria {
    metric_namespace = "Microsoft.Network/trafficManagerProfiles"
    metric_name      = "ProbeAgentCurrentEndpointStateByProfileResourceId"
    aggregation      = "Maximum"
    operator         = "LessThan"
    threshold        = var.endpoint_health_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "EndpointHealth"
  })
}

# Traffic Manager - Probe Agent Current Endpoint State Alert
resource "azurerm_monitor_metric_alert" "probe_agent_endpoint_state" {
  for_each            = data.azurerm_traffic_manager_profile.traffic_manager_profiles
  name                = "TrafficManager-probe-agent-state-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Traffic Manager ${each.value.name} probe agent detects endpoint state changes"
  severity            = 2
  frequency           = var.evaluation_frequency_high
  window_size         = var.window_duration_short
  enabled             = var.enable_probe_agent_monitoring_alert

  criteria {
    metric_namespace = "Microsoft.Network/trafficManagerProfiles"
    metric_name      = "ProbeAgentCurrentEndpointStateByProfileResourceId"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.probe_agent_current_endpoint_state_by_profile_resource_id_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ProbeMonitoring"
  })
}

# =======================================================================================
# ACTIVITY LOG ALERTS
# =======================================================================================

# Activity Log Alert - Traffic Manager Profile Creation
resource "azurerm_monitor_activity_log_alert" "traffic_manager_creation" {
  count               = var.enable_traffic_manager_creation_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "TrafficManager-Creation-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Traffic Manager profile is created"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Network/trafficManagerProfiles"
    operation_name = "Microsoft.Network/trafficManagerProfiles/write"
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

# Activity Log Alert - Traffic Manager Profile Deletion
resource "azurerm_monitor_activity_log_alert" "traffic_manager_deletion" {
  count               = var.enable_traffic_manager_deletion_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "TrafficManager-Deletion-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when a Traffic Manager profile is deleted"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Network/trafficManagerProfiles"
    operation_name = "Microsoft.Network/trafficManagerProfiles/delete"
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

# Activity Log Alert - Traffic Manager Configuration Changes
resource "azurerm_monitor_activity_log_alert" "traffic_manager_config_change" {
  count               = var.enable_traffic_manager_config_change_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "TrafficManager-ConfigChange-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when Traffic Manager profile configuration is modified"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Network/trafficManagerProfiles"
    operation_name = "Microsoft.Network/trafficManagerProfiles/write"
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

# Activity Log Alert - Traffic Manager Endpoint Operations
resource "azurerm_monitor_activity_log_alert" "endpoint_operations" {
  count               = var.enable_endpoint_operations_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "TrafficManager-EndpointOps-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert triggered when Traffic Manager endpoints are created, modified, or deleted"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.Network/trafficManagerProfiles"
    operation_name = "Microsoft.Network/trafficManagerProfiles/write"
    category       = "Administrative"
    level          = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "EndpointManagement"
  })
}

# =======================================================================================
# SCHEDULED QUERY RULES (LOG ANALYTICS BASED)
# =======================================================================================

# Scheduled Query Rule - DNS Resolution Failures
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "dns_resolution_failure" {
  count                = var.enable_dns_resolution_failure_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                 = "TrafficManager-DNSFailure-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_medium
  window_duration      = var.window_duration_medium
  scopes               = local.subscription_scopes
  severity             = 1
  description          = "Alert when Traffic Manager DNS resolution failures are detected"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(15m)
      | where ResourceProvider == "Microsoft.Network"
      | where Resource has "trafficManagerProfiles"
      | where ActivityStatus == "Failed"
      | where OperationName has_any ("Microsoft.Network/dnszones/", "Microsoft.Network/trafficManagerProfiles/")
      | project TimeGenerated, ResourceGroup, Resource, ActivityStatus, OperationName, Properties
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
    alert_type = "DNSResolution"
  })
}

# Scheduled Query Rule - Traffic Manager Endpoint Health Degradation
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "endpoint_health_degradation" {
  count                = var.enable_endpoint_health_alert && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                 = "TrafficManager-EndpointHealth-Alert-${join("-", var.traffic_manager_profile_names)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_medium
  window_duration      = var.window_duration_medium
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when Traffic Manager endpoint health degrades significantly"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(15m)
      | where ResourceProvider == "Microsoft.Network"
      | where Resource has "trafficManagerProfiles"
      | where Properties contains "endpoint"
      | where ActivityStatus has_any ("Failed", "Warning")
      | where OperationName has_any ("Microsoft.Network/trafficManagerProfiles/write", "Microsoft.Network/trafficManagerProfiles/checkTrafficManagerNameAvailability/action")
      | project TimeGenerated, ResourceGroup, Resource, ActivityStatus, OperationName, Caller
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
    alert_type = "EndpointHealthDegradation"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Traffic Manager Activity Logs to Event Hub for external SIEM integration
resource "azurerm_monitor_diagnostic_setting" "trafficmanager_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.traffic_manager_profile_names) : []

  name                           = "send-trafficmanager-logs-to-eventhub"
  target_resource_id             = data.azurerm_traffic_manager_profile.traffic_manager_profiles[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Traffic Manager Log Categories
  enabled_log {
    category = "ProbeHealthStatusEvents"
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

# Send Traffic Manager Security Logs to Log Analytics Workspace for analysis
resource "azurerm_monitor_diagnostic_setting" "trafficmanager_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.traffic_manager_profile_names) : []

  name                       = "send-trafficmanager-logs-to-loganalytics"
  target_resource_id         = data.azurerm_traffic_manager_profile.traffic_manager_profiles[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Traffic Manager Log Categories
  enabled_log {
    category = "ProbeHealthStatusEvents"
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
