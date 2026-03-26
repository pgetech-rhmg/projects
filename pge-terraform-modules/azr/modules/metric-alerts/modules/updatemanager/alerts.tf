# AMBA Alerts for Azure Update Manager
# This file contains comprehensive monitoring alerts for Azure Update Manager operations

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for action group
data "azurerm_monitor_action_group" "pge_operations" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# Activity Log Alert - Update Deployment Started
resource "azurerm_monitor_activity_log_alert" "update_deployment_started" {
  count               = var.enable_update_deployment_failure_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "update-deployment-started-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when Update Manager deployment is started"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Maintenance"
    resource_type     = "Microsoft.Maintenance/maintenanceConfigurations"
    operation_name    = "Microsoft.Maintenance/maintenanceConfigurations/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "update-deployment-started"
  })
}

# Activity Log Alert - Update Deployment Failed
resource "azurerm_monitor_activity_log_alert" "update_deployment_failed" {
  count               = var.enable_update_deployment_failure_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "update-deployment-failed-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when Update Manager deployment fails"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Maintenance"
    resource_type     = "Microsoft.Maintenance/applyUpdates"
    operation_name    = "Microsoft.Maintenance/applyUpdates/write"
    category          = "Administrative"
    status            = "Failed"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "update-deployment-failed"
  })
}

# Activity Log Alert - Maintenance Configuration Changes
resource "azurerm_monitor_activity_log_alert" "maintenance_config_change" {
  count               = var.enable_maintenance_window_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "maintenance-config-change-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when Maintenance Configuration is modified"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Maintenance"
    resource_type     = "Microsoft.Maintenance/maintenanceConfigurations"
    operation_name    = "Microsoft.Maintenance/maintenanceConfigurations/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "maintenance-config-change"
  })
}

# Activity Log Alert - Maintenance Configuration Deleted
resource "azurerm_monitor_activity_log_alert" "maintenance_config_deleted" {
  count               = var.enable_maintenance_window_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "maintenance-config-deleted-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when Maintenance Configuration is deleted"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Maintenance"
    resource_type     = "Microsoft.Maintenance/maintenanceConfigurations"
    operation_name    = "Microsoft.Maintenance/maintenanceConfigurations/delete"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "maintenance-config-deleted"
  })
}

# Activity Log Alert - Update Assessment Triggered
resource "azurerm_monitor_activity_log_alert" "update_assessment_triggered" {
  count               = var.enable_update_assessment_failure_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "update-assessment-triggered-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when Update Assessment is triggered"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Maintenance"
    resource_type     = "Microsoft.Maintenance/configurationAssignments"
    operation_name    = "Microsoft.Maintenance/configurationAssignments/write"
    category          = "Administrative"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "update-assessment-triggered"
  })
}

# Activity Log Alert - VM Update Installation Failed
resource "azurerm_monitor_activity_log_alert" "vm_update_failed" {
  count               = var.enable_patch_installation_failure_alert && length(var.subscription_ids) > 0 ? 1 : 0
  name                = "vm-update-failed-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [for sub_id in var.subscription_ids : "/subscriptions/${sub_id}"]
  description         = "Alert when VM update installation fails"
  enabled             = true

  criteria {
    resource_provider = "Microsoft.Compute"
    resource_type     = "Microsoft.Compute/virtualMachines"
    operation_name    = "Microsoft.Compute/virtualMachines/extensions/write"
    category          = "Administrative"
    status            = "Failed"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.pge_operations.id
  }

  tags = merge(var.tags, {
    alert_type = "vm-update-failed"
  })
}

# Scheduled Query Rule Alert - Update Compliance Monitoring
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "update_compliance_low" {
  count                = var.enable_update_compliance_alert && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                 = "update-compliance-low-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "P1D"
  window_duration      = "P1D"
  scopes               = var.vm_resource_ids
  severity             = 2
  description          = "Alert when VM update compliance drops below ${var.update_compliance_threshold}%"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Update
      | where TimeGenerated > ago(1d)
      | where UpdateState == "Needed"
      | summarize 
          TotalUpdates = count(),
          CriticalUpdates = countif(Classification == "Critical Updates"),
          SecurityUpdates = countif(Classification == "Security Updates")
      | extend ComplianceRate = 100 - (TotalUpdates * 100 / (TotalUpdates + 1))
      | where ComplianceRate < ${var.update_compliance_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "update-compliance"
  })
}

# Scheduled Query Rule Alert - Critical Updates Available
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "critical_updates_available" {
  count                = var.enable_critical_update_available_alert && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                 = "critical-updates-available-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "P1D"
  window_duration      = "P1D"
  scopes               = var.vm_resource_ids
  severity             = 1
  description          = "Alert when critical updates are available for VMs"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Update
      | where TimeGenerated > ago(1d)
      | where UpdateState == "Needed" 
      | where Classification in ("Critical Updates", "Security Updates")
      | summarize CriticalUpdates = count() by Computer
      | where CriticalUpdates >= ${var.critical_update_available_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "critical-updates-available"
  })
}

# Scheduled Query Rule Alert - Update Installation Failures
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "update_installation_failures" {
  count                = var.enable_patch_installation_failure_alert && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                 = "update-installation-failures-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT1H"
  window_duration      = "PT6H"
  scopes               = var.vm_resource_ids
  severity             = 1
  description          = "Alert when update installations fail on VMs"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Update
      | where TimeGenerated > ago(6h)
      | where UpdateState == "Failed"
      | summarize FailedUpdates = count() by Computer, Classification
      | where FailedUpdates >= ${var.patch_installation_failure_threshold}
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "update-installation-failures"
  })
}

# Scheduled Query Rule Alert - Update Assessment Failures
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "update_assessment_failures" {
  count                = var.enable_update_assessment_failure_alert && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                 = "update-assessment-failures-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT6H"
  window_duration      = "PT6H"
  scopes               = var.vm_resource_ids
  severity             = 2
  description          = "Alert when update assessments fail on VMs"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      UpdateSummary
      | where TimeGenerated > ago(12h)
      | where ManagementGroupName != ""
      | summarize 
          LastAssessment = max(TimeGenerated),
          AssessmentStatus = any(OldestMissingSecurityUpdateInDays)
      | where LastAssessment < ago(24h) or AssessmentStatus == -1
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = var.update_assessment_failure_threshold - 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "update-assessment-failures"
  })
}

# Scheduled Query Rule Alert - Maintenance Window Violations
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "maintenance_window_violations" {
  count                = var.enable_maintenance_window_alert && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                 = "maintenance-window-violations-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT1H"
  window_duration      = "PT1H"
  scopes               = var.vm_resource_ids
  severity             = 2
  description          = "Alert when updates are installed outside maintenance windows"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Update
      | where TimeGenerated > ago(1h)
      | where UpdateState == "Installed"
      | extend Hour = datetime_part("hour", TimeGenerated)
      | extend DayOfWeek = dayofweek(TimeGenerated)
      | where Hour < 2 or Hour > 6  // Outside typical maintenance window (2-6 AM)
      | where DayOfWeek != 0d and DayOfWeek != 6d  // Not weekend
      | count
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.pge_operations.id]
  }

  tags = merge(var.tags, {
    alert_type = "maintenance-window-violations"
  })
}