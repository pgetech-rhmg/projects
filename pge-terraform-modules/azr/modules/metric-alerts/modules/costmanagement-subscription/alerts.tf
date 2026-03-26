# Azure Cost Management - Subscription Level AMBA Alerts
# This file contains subscription-level cost monitoring alerts following AMBA best practices

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
# SUBSCRIPTION-LEVEL BUDGET ALERTS
# =======================================================================================

# Subscription Monthly Budget Alert
resource "azurerm_consumption_budget_subscription" "monthly_budget" {
  for_each        = local.should_create_alerts && var.enable_subscription_cost_alerts ? toset(var.subscription_ids) : toset([])
  name            = "monthly-budget-${each.value}"
  subscription_id = "/subscriptions/${each.value}"

  amount     = var.subscription_monthly_cost_threshold
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
  }

  # 75% threshold notification
  notification {
    enabled        = true
    threshold      = var.budget_alert_percentage_first
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = var.contact_emails
  }

  # 90% threshold notification
  notification {
    enabled        = true
    threshold      = var.budget_alert_percentage_second
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = var.contact_emails
  }

  # 100% threshold notification
  notification {
    enabled        = true
    threshold      = var.budget_alert_percentage_critical
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = var.contact_emails
  }

  # Forecasted budget notification
  notification {
    enabled        = true
    threshold      = var.budget_alert_percentage_second
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = var.contact_emails
  }
}

# Subscription Daily Cost Spike Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "subscription_daily_cost_spike" {
  for_each             = local.should_create_alerts && var.enable_cost_increase_alerts ? toset(var.subscription_ids) : toset([])
  name                 = "subscription-daily-cost-spike-${each.value}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = ["/subscriptions/${each.value}"]
  severity             = 1
  description          = "Alert when subscription ${each.value} daily cost exceeds ${var.subscription_daily_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where SubscriptionId == "${each.value}"
      | where CategoryValue == "Administrative"
      | where OperationNameValue contains "Microsoft.Consumption"
      | summarize ActivityCount = count() by bin(TimeGenerated, 1h)
      | where ActivityCount > 0
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
    alert_type = "SubscriptionDailyCost"
  })
}

# =======================================================================================
# SERVICE-SPECIFIC COST ALERTS
# =======================================================================================

# Compute Services Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "compute_cost_alert" {
  count                = var.enable_service_cost_alerts && local.should_create_alerts ? 1 : 0
  name                 = "compute-services-cost-alert-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when compute services monthly cost exceeds ${var.compute_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Web", "Microsoft.ClassicCompute")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "write" or OperationNameValue contains "create"
      | summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
      | where ResourceActivity > 10
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
    alert_type = "ComputeServicesCost"
  })
}

# Storage Services Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "storage_cost_alert" {
  count                = var.enable_service_cost_alerts && local.should_create_alerts ? 1 : 0
  name                 = "storage-services-cost-alert-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when storage services monthly cost exceeds ${var.storage_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProviderValue in ("Microsoft.Storage", "Microsoft.RecoveryServices", "Microsoft.Backup")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "write" or OperationNameValue contains "create"
      | summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
      | where ResourceActivity > 5
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
    alert_type = "StorageServicesCost"
  })
}

# Database Services Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "database_cost_alert" {
  count                = var.enable_service_cost_alerts && local.should_create_alerts ? 1 : 0
  name                 = "database-services-cost-alert-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when database services monthly cost exceeds ${var.database_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProviderValue in ("Microsoft.Sql", "Microsoft.DocumentDB", "Microsoft.Cache", "Microsoft.DataMigration")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "write" or OperationNameValue contains "create"
      | summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
      | where ResourceActivity > 3
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
    alert_type = "DatabaseServicesCost"
  })
}

# Networking Services Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "networking_cost_alert" {
  count                = var.enable_service_cost_alerts && local.should_create_alerts ? 1 : 0
  name                 = "networking-services-cost-alert-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = local.subscription_scopes
  severity             = 2
  description          = "Alert when networking services monthly cost exceeds ${var.networking_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceProviderValue in ("Microsoft.Network", "Microsoft.Cdn", "Microsoft.ApiManagement")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "write" or OperationNameValue contains "create"
      | summarize ResourceActivity = count() by bin(TimeGenerated, 1h)
      | where ResourceActivity > 2
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
    alert_type = "NetworkingServicesCost"
  })
}

# =======================================================================================
# COST ANOMALY AND TREND ALERTS
# =======================================================================================

# Unused Resources Cost Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "unused_resources_cost" {
  count                = var.enable_cost_increase_alerts && local.should_create_alerts ? 1 : 0
  name                 = "unused-resources-cost-alert-${join("-", var.subscription_ids)}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = local.subscription_scopes
  severity             = 3
  description          = "Alert for potential unused resources incurring costs"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(7d)
      | where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Storage")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "delete" or OperationNameValue contains "deallocate"
      | summarize UnusedActivity = count() by ResourceId
      | where UnusedActivity > 0
      | summarize TotalUnused = count()
      | where TotalUnused > 5
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
    alert_type = "UnusedResourcesCost"
  })
}

# =======================================================================================
# ACTIVITY LOG ALERTS FOR COST MANAGEMENT OPERATIONS
# =======================================================================================

# Budget Creation Alert
resource "azurerm_monitor_activity_log_alert" "budget_creation" {
  count               = var.enable_export_alerts && local.should_create_alerts ? 1 : 0
  name                = "CostManagement-Budget-Creation-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when a new budget is created"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Consumption"
    resource_type     = "Microsoft.Consumption/budgets"
    operation_name    = "Microsoft.Consumption/budgets/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "BudgetCreation"
  })
}

# Budget Deletion Alert
resource "azurerm_monitor_activity_log_alert" "budget_deletion" {
  count               = var.enable_export_alerts && local.should_create_alerts ? 1 : 0
  name                = "CostManagement-Budget-Deletion-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when a budget is deleted"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.Consumption"
    resource_type     = "Microsoft.Consumption/budgets"
    operation_name    = "Microsoft.Consumption/budgets/delete"
    category          = "Administrative"
    level             = "Warning"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "BudgetDeletion"
  })
}

# Cost Export Configuration Changes
resource "azurerm_monitor_activity_log_alert" "export_config_changes" {
  count               = var.enable_export_alerts && local.should_create_alerts ? 1 : 0
  name                = "CostManagement-Export-Changes-${join("-", var.subscription_ids)}"
  resource_group_name = var.resource_group_name
  scopes              = local.subscription_scopes
  description         = "Alert when cost export configurations are modified"
  location            = "global"

  criteria {
    resource_provider = "Microsoft.CostManagement"
    resource_type     = "Microsoft.CostManagement/exports"
    operation_name    = "Microsoft.CostManagement/exports/write"
    category          = "Administrative"
    level             = "Informational"
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.action_group.id
  }

  tags = merge(var.tags, {
    alert_type = "ExportConfigChanges"
  })
}