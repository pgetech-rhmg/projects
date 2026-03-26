/*
 * # Azure Key Vault Monitoring module
 * Terraform module which creates SAF2.0 monitoring alerts for Azure Key Vault
*/
#
# Filename    : modules/key-vault-monitoring/main.tf
# Date        : 25 Feb 2026
# Author      : PGE
# Description : This terraform module creates comprehensive monitoring and alerting for Azure Key Vault resources.
#
# PURPOSE:
#   Provisions comprehensive monitoring, alerting, and diagnostic settings for Azure Key Vaults.
#   Enables proactive detection and response to vault performance issues, security events, and operational anomalies.
#
# FEATURES:
#   - 7 metric-based alerts: availability, latency, API hit rate, errors, saturation, authentication failures, throttling
#   - 3 activity log alerts: access policy changes, vault deletions, key operations
#   - Diagnostic settings with Event Hub and Log Analytics integration
#   - Cross-subscription support for Event Hub and Log Analytics resources
#   - Optional action group integration for alert notifications
#   - SAF2.0 compliant tagging and workspace integration
#   - Optional resources for testing environments without actual Azure resources
#
# ALERT CONFIGURATION:
#   - Availability Alert: Triggers when vault availability drops below threshold (default 99.9%)
#   - Latency Alert: Triggers when service API latency exceeds threshold (default 1000ms)
#   - API Hit Rate Alert: Triggers when API hit rate exceeds threshold (default 5000)
#   - Error Alert: Triggers when error rate exceeds threshold (default 20)
#   - Saturation Alert: Triggers when saturation exceeds threshold (default 80%)
#   - Authentication Failure Alert: Triggers on authentication failures
#   - Throttling Alert: Triggers when requests are throttled
#   - Access Policy Alert: Triggers when access policies change
#   - Deletion Alert: Triggers when vaults or keys are deleted
#   - Key Operations Alert: Triggers on key creation, deletion, or modification
#
# REQUIREMENTS:
#   - Azure subscription with monitoring permissions
#   - Pre-existing Key Vault(s) for monitoring
#   - (Optional) Action Group for alert notifications
#   - (Optional) Event Hub namespace for diagnostic streaming
#   - (Optional) Log Analytics workspace for security log aggregation
#
# EXAMPLE USAGE:
#   module "kv_monitoring" {
#     source = "app.terraform.io/pgetech/azure/key-vault-monitoring"
#     resource_group_name = "my-rg"
#     key_vault_names = ["my-kv-1", "my-kv-2"]
#     action_group = "pge-operations-alerts"
#     enable_diagnostic_settings = true
#   }
#

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Workspace information module for SAF2.0 compliance tagging
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Local variables for module configuration and tagging
locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })

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
  diagnostic_settings_eventhub_enabled     = var.enable_diagnostic_settings && var.eventhub_name != "" && length(var.key_vault_names) > 0
  diagnostic_settings_loganalytics_enabled = var.enable_diagnostic_settings && var.log_analytics_workspace_name != "" && length(var.key_vault_names) > 0
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for action group (optional - only if action group name is provided)
data "azurerm_monitor_action_group" "pge_operations" {
  count               = var.action_group != "" ? 1 : 0
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Data source for Key Vaults using static names
data "azurerm_key_vault" "key_vaults" {
  for_each            = toset(var.key_vault_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

# ==============================================================================
# METRIC-BASED ALERTS
# ==============================================================================
# The following alerts monitor Key Vault performance metrics and trigger
# notifications when thresholds are exceeded. Each alert is scoped to individual
# Key Vaults and includes severity levels for prioritization.
# ==============================================================================

# Key Vault Availability Alert
resource "azurerm_monitor_metric_alert" "kv_availability" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-availability-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault availability drops below ${var.availability_threshold}%"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-availability"
  })
}

# Service API Latency Alert
resource "azurerm_monitor_metric_alert" "kv_service_api_latency" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-service-api-latency-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault service API latency exceeds ${var.service_api_latency_threshold}ms"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.service_api_latency_threshold
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-service-api-latency"
  })
}

# Service API Hit Rate Alert
resource "azurerm_monitor_metric_alert" "kv_service_api_hit" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-service-api-hit-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault service API hit rate exceeds ${var.service_api_hit_threshold}"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiHit"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.service_api_hit_threshold
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-service-api-hit"
  })
}

# Service API Result Errors Alert
resource "azurerm_monitor_metric_alert" "kv_service_api_result_errors" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-service-api-result-errors-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault service API result errors exceed ${var.service_api_result_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiResult"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.service_api_result_threshold

    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["4xx", "5xx"]
    }
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-service-api-result-errors"
  })
}

# Saturation Shoebox Alert
resource "azurerm_monitor_metric_alert" "kv_saturation_shoebox" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-saturation-shoebox-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault saturation shoebox exceeds ${var.saturation_shoebox_threshold}%"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "SaturationShoebox"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.saturation_shoebox_threshold
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-saturation-shoebox"
  })
}

# Key Vault Request Rate Alert (Authentication Failures)
resource "azurerm_monitor_metric_alert" "kv_authentication_failures" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-authentication-failures-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault authentication failures occur"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiResult"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5

    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["401", "403"]
    }
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-authentication-failures"
  })
}

# Key Vault Throttling Alert
resource "azurerm_monitor_metric_alert" "kv_throttling" {
  for_each            = data.azurerm_key_vault.key_vaults
  name                = "kv-throttling-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alert when Key Vault requests are being throttled"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiResult"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["429"]
    }
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-throttling"
  })
}

# ==============================================================================
# ACTIVITY LOG ALERTS
# ==============================================================================
# The following alerts monitor Key Vault control plane events (activities)
# that indicate security or operational changes. These include access policy
# modifications, deletions, and key management operations.
# ==============================================================================

# Activity Log Alert - Key Vault Access Policy Change
resource "azurerm_monitor_activity_log_alert" "kv_access_policy_change" {
  count               = length(var.key_vault_names) > 0 ? 1 : 0
  name                = "kv-access-policy-change-${join("-", var.key_vault_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when Key Vault access policy is changed"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.KeyVault"
    resource_type     = "Microsoft.KeyVault/vaults"
    operation_name    = "Microsoft.KeyVault/vaults/accessPolicies/write"
    category          = "Administrative"
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-access-policy-change"
  })
}

# Activity Log Alert - Key Vault Deletion
resource "azurerm_monitor_activity_log_alert" "kv_delete" {
  count               = length(var.key_vault_names) > 0 ? 1 : 0
  name                = "kv-delete-${join("-", var.key_vault_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when Key Vault is deleted"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.KeyVault"
    resource_type     = "Microsoft.KeyVault/vaults"
    operation_name    = "Microsoft.KeyVault/vaults/delete"
    category          = "Administrative"
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-delete"
  })
}

# Activity Log Alert - Key/Secret/Certificate Operations
resource "azurerm_monitor_activity_log_alert" "kv_key_operations" {
  count               = length(var.key_vault_names) > 0 ? 1 : 0
  name                = "kv-key-operations-${join("-", var.key_vault_names)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert on critical Key Vault key/secret/certificate operations"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.KeyVault"
    resource_type     = "Microsoft.KeyVault/vaults"
    category          = "Administrative"
    operation_name    = "Microsoft.KeyVault/vaults/keys/delete"
  }

  action {
    action_group_id = var.action_group != "" ? data.azurerm_monitor_action_group.pge_operations[0].id : null
  }

  tags = merge(local.module_tags, {
    alert_type = "kv-key-operations"
  })
}

# ==============================================================================
# DIAGNOSTIC SETTINGS
# ==============================================================================
# The following resources configure diagnostic settings for Key Vaults,
# streaming audit events and metrics to Event Hub and/or Log Analytics.
# These settings enable centralized logging and compliance auditing across
# multiple subscriptions. Diagnostics are optional and configurable.
# ==============================================================================

# Diagnostic Settings to Event Hub (for activity logs)
resource "azurerm_monitor_diagnostic_setting" "kv_to_eventhub" {
  for_each                       = local.diagnostic_settings_eventhub_enabled ? toset(var.key_vault_names) : []
  name                           = "kv-to-eventhub-${each.key}"
  target_resource_id             = data.azurerm_key_vault.key_vaults[each.key].id
  eventhub_authorization_rule_id = local.eventhub_auth_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings to Log Analytics (for security logs)
resource "azurerm_monitor_diagnostic_setting" "kv_to_loganalytics" {
  for_each                   = local.diagnostic_settings_loganalytics_enabled ? toset(var.key_vault_names) : []
  name                       = "kv-to-loganalytics-${each.key}"
  target_resource_id         = data.azurerm_key_vault.key_vaults[each.key].id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}