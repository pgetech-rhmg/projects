# Azure Automation Account AMBA Alerts
# This file creates comprehensive monitoring alerts for Azure Automation Accounts
# following Azure Monitor Baseline Alerts (AMBA) best practices

# Data source for action group
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for current subscription
data "azurerm_client_config" "current" {}

# Create scopes lists - empty arrays disable alert creation
locals {
  # Subscription-level alerts (activity log alerts) - empty array disables all alerts
  subscription_scopes = length(var.subscription_ids) > 0 ? [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"] : []
  # Resource-level alerts (scheduled query rules) - empty array disables resource-specific alerts
  automation_resource_scopes = length(var.automation_account_resource_ids) > 0 ? var.automation_account_resource_ids : []

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && length(var.automation_account_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.automation_account_names) > 0
}

# 1. Activity Log Alert: Automation Account Creation
resource "azurerm_monitor_activity_log_alert" "automation_account_creation" {
  count               = var.enable_automation_account_creation_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AutomationAccount-Creation-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Automation Account creation operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts"
    operation_name    = "Microsoft.Automation/automationAccounts/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResourceCreation"
  })
}

# 2. Activity Log Alert: Automation Account Deletion
resource "azurerm_monitor_activity_log_alert" "automation_account_deletion" {
  count               = var.enable_automation_account_deletion_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AutomationAccount-Deletion-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Automation Account deletion operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts"
    operation_name    = "Microsoft.Automation/automationAccounts/delete"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ResourceDeletion"
  })
}

# 3. Activity Log Alert: Runbook Operations
resource "azurerm_monitor_activity_log_alert" "runbook_operations" {
  count               = var.enable_runbook_operations_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AutomationAccount-RunbookOperations-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Runbook creation, modification, and deletion operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts/runbooks"
    operation_name    = "Microsoft.Automation/automationAccounts/runbooks/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "RunbookManagement"
  })
}

# 4. Activity Log Alert: Hybrid Worker Operations
resource "azurerm_monitor_activity_log_alert" "hybrid_worker_operations" {
  count               = var.enable_hybrid_worker_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AutomationAccount-HybridWorkerOperations-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Hybrid Worker registration and deregistration operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts/hybridRunbookWorkerGroups"
    operation_name    = "Microsoft.Automation/automationAccounts/hybridRunbookWorkerGroups/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "HybridWorkerManagement"
  })
}

# 5. Activity Log Alert: Update Deployment Operations
resource "azurerm_monitor_activity_log_alert" "update_deployment_operations" {
  count               = var.enable_update_deployment_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "UpdateDeploymentOperations-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Update Deployment creation and modification operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts/softwareUpdateConfigurations"
    operation_name    = "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "UpdateManagement"
  })
}

# 6. Activity Log Alert: Webhook Operations
resource "azurerm_monitor_activity_log_alert" "webhook_operations" {
  count               = var.enable_webhook_alert && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "AutomationAccount-WebhookOperations-${join("-", var.automation_account_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  description         = "Monitors for Webhook creation, modification, and deletion operations"

  scopes = local.subscription_scopes

  criteria {
    resource_provider = "Microsoft.Automation"
    resource_type     = "automationAccounts/webhooks"
    operation_name    = "Microsoft.Automation/automationAccounts/webhooks/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "WebhookManagement"
  })
}
# =======================================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOGS TO EVENT HUB & SECURITY LOGS TO LOG ANALYTICS
# =======================================================================================

# Data source for Automation Accounts
data "azurerm_automation_account" "automation_accounts" {
  for_each            = toset(var.automation_account_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# Diagnostic Setting 1: Automation Account - Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "automationaccount_to_eventhub" {
  for_each           = local.diagnostic_settings_eventhub_enabled ? data.azurerm_automation_account.automation_accounts : {}
  name               = "automationaccount-activity-logs-to-eventhub-${each.value.name}"
  target_resource_id = each.value.id

  # Send activity logs to Event Hub
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  # Activity Logs - Automation Account operations
  enabled_log {
    category = "JobLogs"
  }

  enabled_log {
    category = "JobStreams"
  }

  enabled_log {
    category = "DscNodeStatus"
  }

  # Metrics for monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Setting 2: Automation Account - Security Logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "automationaccount_to_loganalytics" {
  for_each           = local.diagnostic_settings_loganalytics_enabled ? data.azurerm_automation_account.automation_accounts : {}
  name               = "automationaccount-security-logs-to-loganalytics-${each.value.name}"
  target_resource_id = each.value.id

  # Send security logs to Log Analytics
  log_analytics_workspace_id = local.log_analytics_workspace_id

  # Security-relevant logs
  enabled_log {
    category = "JobLogs"
  }

  enabled_log {
    category = "JobStreams"
  }

  enabled_log {
    category = "DscNodeStatus"
  }

  # Metrics for security monitoring
  enabled_metric {
    category = "AllMetrics"
  }
}
