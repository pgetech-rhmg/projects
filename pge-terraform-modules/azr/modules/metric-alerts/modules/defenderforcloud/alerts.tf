# Azure Security Center (Microsoft Defender for Cloud) AMBA Alerts
# This file contains activity log monitoring alerts for Azure Security Center following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.subscription_ids) > 0
  subscription_scopes  = var.subscription_ids != [] ? [for id in var.subscription_ids : "/subscriptions/${id}"] : []
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# =======================================================================================
# MICROSOFT DEFENDER PLAN STATUS ALERTS (ACTIVITY LOG BASED)
# =======================================================================================

# Microsoft Defender Plan Status Change Alert
resource "azurerm_monitor_activity_log_alert" "defender_plan_status_change" {
  count               = var.enable_defender_plan_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-DefenderPlan-StatusChange-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Microsoft Defender plan status changes"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/pricings"
    operation_name    = "Microsoft.Security/pricings/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "DefenderPlanStatusChange"
  })
}

# Security Policy Assignment Changes
resource "azurerm_monitor_activity_log_alert" "security_policy_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-SecurityPolicy-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when security policy assignments are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Authorization"
    resource_type     = "Microsoft.Authorization/policyAssignments"
    operation_name    = "Microsoft.Authorization/policyAssignments/write"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "SecurityPolicyChanges"
  })
}

# Security Policy Assignment Deletions
resource "azurerm_monitor_activity_log_alert" "security_policy_deletions" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-SecurityPolicy-Deletions-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when security policy assignments are deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Authorization"
    resource_type     = "Microsoft.Authorization/policyAssignments"
    operation_name    = "Microsoft.Authorization/policyAssignments/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "SecurityPolicyDeletions"
  })
}

# Security Center Settings Changes
resource "azurerm_monitor_activity_log_alert" "security_center_settings_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-Settings-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Security Center settings are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/securityContacts"
    operation_name    = "Microsoft.Security/securityContacts/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "SecurityCenterSettingsChanges"
  })
}

# Security Center Auto Provisioning Changes
resource "azurerm_monitor_activity_log_alert" "security_center_auto_provisioning_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-AutoProvisioning-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Security Center auto provisioning settings are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/autoProvisioningSettings"
    operation_name    = "Microsoft.Security/autoProvisioningSettings/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "AutoProvisioningChanges"
  })
}

# Security Assessment Changes
resource "azurerm_monitor_activity_log_alert" "security_assessment_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-SecurityAssessment-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when security assessments are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/assessments"
    operation_name    = "Microsoft.Security/assessments/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "SecurityAssessmentChanges"
  })
}

# Security Alert Rule Changes
resource "azurerm_monitor_activity_log_alert" "security_alert_rule_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-AlertRule-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when security alert rules are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/alertsSuppressionRules"
    operation_name    = "Microsoft.Security/alertsSuppressionRules/write"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "SecurityAlertRuleChanges"
  })
}

# Security Center Workflow Automation Changes
resource "azurerm_monitor_activity_log_alert" "workflow_automation_changes" {
  count               = var.enable_policy_alerts && local.should_create_alerts && length(local.subscription_scopes) > 0 ? 1 : 0
  name                = "SecurityCenter-WorkflowAutomation-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when Security Center workflow automation is modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Security"
    resource_type     = "Microsoft.Security/automations"
    operation_name    = "Microsoft.Security/automations/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "WorkflowAutomationChanges"
  })
}