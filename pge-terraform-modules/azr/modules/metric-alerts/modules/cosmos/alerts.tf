# Cosmos DB Metric Alerts
# This file contains metric alerts for Azure Cosmos DB monitoring following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.cosmos_account_names) > 0

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
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get Cosmos DB accounts using static names
data "azurerm_cosmosdb_account" "cosmos_accounts" {
  for_each            = local.should_create_alerts ? toset(var.cosmos_account_names) : toset([])
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Cosmos DB - Availability Alert
resource "azurerm_monitor_metric_alert" "cosmos_availability" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} availability is below threshold"
  severity            = 1
  frequency           = "PT1H"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ServiceAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.cosmos_availability_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Availability"
  })
}

# Cosmos DB - Server Side Latency Alert
resource "azurerm_monitor_metric_alert" "cosmos_server_side_latency" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-server-side-latency-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} server side latency is above threshold"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ServerSideLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cosmos_server_side_latency_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Cosmos DB - Request Units (RU) Consumption Alert
resource "azurerm_monitor_metric_alert" "cosmos_ru_consumption" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-ru-consumption-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} RU consumption is above threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "TotalRequestUnits"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cosmos_ru_consumption_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Cosmos DB - Normalized RU Consumption Alert (Critical)
resource "azurerm_monitor_metric_alert" "cosmos_normalized_ru_consumption" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-normalized-ru-consumption-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} normalized RU consumption is critically high"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "NormalizedRUConsumption"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.cosmos_normalized_ru_consumption_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Performance"
  })
}

# Cosmos DB - Total Requests Alert (High Volume)
resource "azurerm_monitor_metric_alert" "cosmos_total_requests" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-total-requests-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} total requests volume is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "TotalRequests"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.cosmos_total_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Cosmos DB - Metadata Requests Alert
resource "azurerm_monitor_metric_alert" "cosmos_metadata_requests" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-metadata-requests-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} metadata requests are high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "MetadataRequests"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.cosmos_metadata_requests_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Usage"
  })
}

# Cosmos DB - Data Usage Alert
resource "azurerm_monitor_metric_alert" "cosmos_data_usage" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-data-usage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} data usage is above threshold"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "DataUsage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cosmos_data_usage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Capacity"
  })
}

# Cosmos DB - Index Usage Alert
resource "azurerm_monitor_metric_alert" "cosmos_index_usage" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-index-usage-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} index usage is above threshold"
  severity            = 3
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "IndexUsage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cosmos_index_usage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Capacity"
  })
}

# Cosmos DB - Provisioned Throughput Alert
resource "azurerm_monitor_metric_alert" "cosmos_provisioned_throughput" {
  for_each            = data.azurerm_cosmosdb_account.cosmos_accounts
  name                = "cosmos-provisioned-throughput-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Cosmos DB ${each.value.name} provisioned throughput utilization is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ProvisionedThroughput"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.cosmos_provisioned_throughput_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Capacity"
  })
}

# Activity Log Alert - Cosmos DB Account Delete
resource "azurerm_monitor_activity_log_alert" "cosmos_account_delete" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts ? 1 : 0
  name                = "cosmos-account-delete"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when a Cosmos DB account is deleted"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.DocumentDB/databaseAccounts"
    operation_name = "Microsoft.DocumentDB/databaseAccounts/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Administrative"
  })
}

# Activity Log Alert - Cosmos DB Account Configuration Change
resource "azurerm_monitor_activity_log_alert" "cosmos_account_config_change" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts ? 1 : 0
  name                = "cosmos-account-config-change"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when a Cosmos DB account configuration is changed"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.DocumentDB/databaseAccounts"
    operation_name = "Microsoft.DocumentDB/databaseAccounts/write"
    category       = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Administrative"
  })
}

# Activity Log Alert - Cosmos DB Failover
resource "azurerm_monitor_activity_log_alert" "cosmos_failover" {
  count               = var.enable_activity_log_alerts && local.should_create_alerts ? 1 : 0
  name                = "cosmos-failover"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when a Cosmos DB failover occurs"
  location            = "global"

  criteria {
    resource_type  = "Microsoft.DocumentDB/databaseAccounts"
    operation_name = "Microsoft.DocumentDB/databaseAccounts/failoverPriorityChange/action"
    category       = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "Administrative"
  })
}
# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Diagnostic Setting 1: Cosmos DB - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "cosmos_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? data.azurerm_cosmosdb_account.cosmos_accounts : {}
  name               = "cosmos-activity-logs-to-eventhub-${each.value.name}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Cosmos DB operations
  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_log {
    category = "PartitionKeyRUConsumption"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  # API-specific logs (only generate logs if the API is used)
  enabled_log {
    category = "MongoRequests"
  }

  enabled_log {
    category = "CassandraRequests"
  }

  enabled_log {
    category = "GremlinRequests"
  }

  enabled_log {
    category = "TableApiRequests"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "Requests"
  }
}

# Diagnostic Setting 2: Cosmos DB - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "cosmos_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? data.azurerm_cosmosdb_account.cosmos_accounts : {}
  name               = "cosmos-security-logs-to-loganalytics-${each.value.name}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_log {
    category = "PartitionKeyRUConsumption"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  enabled_log {
    category = "MongoRequests"
  }

  enabled_log {
    category = "CassandraRequests"
  }

  enabled_log {
    category = "GremlinRequests"
  }

  enabled_log {
    category = "TableApiRequests"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "Requests"
  }
}
