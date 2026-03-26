# Storage Account Metric Alerts
# This file contains metric alerts for Azure Storage Accounts monitoring

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && var.eventhub_namespace_name != "" && length(var.storage_account_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.storage_account_names) > 0
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source to get storage accounts using static names
data "azurerm_storage_account" "storage_accounts" {
  for_each            = toset(var.storage_account_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Storage Account Availability Alert
resource "azurerm_monitor_metric_alert" "storage_availability" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account availability drops below 99%"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.storage_availability_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-availability"
  })
}

# Storage Account Success E2E Latency Alert
resource "azurerm_monitor_metric_alert" "storage_latency" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-latency-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account E2E latency exceeds 1000ms"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "SuccessE2ELatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_latency_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-latency"
  })
}

# Storage Account Server Latency Alert
resource "azurerm_monitor_metric_alert" "storage_server_latency" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-server-latency-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account server latency exceeds 500ms"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "SuccessServerLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_server_latency_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-server-latency"
  })
}

# Storage Account Capacity Alert (85% threshold)
resource "azurerm_monitor_metric_alert" "storage_capacity" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-capacity-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account capacity exceeds 85% of quota"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_capacity_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-capacity"
  })
}

# Storage Account Transaction Rate Alert
resource "azurerm_monitor_metric_alert" "storage_transactions" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-transactions-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account transaction rate is unusually high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.storage_transaction_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-transactions"
  })
}

# Storage Account Error Rate Alert
resource "azurerm_monitor_metric_alert" "storage_errors" {
  for_each            = data.azurerm_storage_account.storage_accounts
  name                = "storage-errors-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when storage account error rate exceeds 5%"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "ResponseType"
      operator = "Include"
      values   = ["ClientError", "ServerError", "NetworkError", "ClientThrottlingError", "ServerBusyError"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "storage-errors"
  })
}

#====================================================================================================
# DIAGNOSTIC SETTINGS - Send Activity Logs to Event Hub and Security Logs to Log Analytics Workspace
#====================================================================================================

# Send Storage Account Metrics to Event Hub for external SIEM integration
# Note: Storage accounts at the account level only support metrics, not logs
# For logs, configure diagnostic settings on sub-services (blob, table, queue, file)
resource "azurerm_monitor_diagnostic_setting" "storageaccount_to_eventhub" {
  for_each = local.diagnostic_settings_eventhub_enabled ? toset(var.storage_account_names) : []

  name                           = "send-storageaccount-metrics-to-eventhub"
  target_resource_id             = data.azurerm_storage_account.storage_accounts[each.key].id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id

  # Storage Account only supports metrics at the account level
  # Enable Transaction metrics for Event Hub destination
  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      eventhub_name,
      eventhub_authorization_rule_id,
    ]
  }
}

# Send Storage Account Metrics to Log Analytics Workspace for analysis
# Note: Storage accounts at the account level only support metrics, not logs
# For logs, configure diagnostic settings on sub-services (blob, table, queue, file)
resource "azurerm_monitor_diagnostic_setting" "storageaccount_to_loganalytics" {
  for_each = local.diagnostic_settings_loganalytics_enabled ? toset(var.storage_account_names) : []

  name                       = "send-storageaccount-metrics-to-loganalytics"
  target_resource_id         = data.azurerm_storage_account.storage_accounts[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Storage Account only supports metrics at the account level
  # Metrics enabled for Log Analytics
  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [
      log_analytics_workspace_id,
    ]
  }
}


