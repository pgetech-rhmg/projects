# Azure Cost Management - Resource Group Level AMBA Alerts
# This file contains resource group-level cost monitoring alerts following AMBA best practices

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local variables for conditional alert creation
locals {
  should_create_alerts = length(var.resource_group_names) > 0
  # Use provided subscription_id or current subscription
  target_subscription_id = var.subscription_id != "" ? var.subscription_id : data.azurerm_client_config.current.subscription_id
  resource_group_scopes  = var.resource_group_names != [] ? [for rg in var.resource_group_names : "/subscriptions/${local.target_subscription_id}/resourceGroups/${rg}"] : []
}

# Data sources for existing action groups
data "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group
  resource_group_name = var.action_group_resource_group_name
}

# =======================================================================================
# RESOURCE GROUP-LEVEL BUDGET ALERTS
# =======================================================================================

# Resource Group Monthly Budget Alert
resource "azurerm_consumption_budget_resource_group" "monthly_rg_budget" {
  for_each          = local.should_create_alerts && var.enable_resource_group_cost_alerts ? toset(var.resource_group_names) : toset([])
  name              = "monthly-budget-${each.value}"
  resource_group_id = "/subscriptions/${local.target_subscription_id}/resourceGroups/${each.value}"

  amount     = var.resource_group_monthly_cost_threshold
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
}

# Resource Group Daily Cost Spike Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_group_daily_cost_spike" {
  for_each             = local.should_create_alerts && var.enable_resource_group_trend_alerts ? toset(var.resource_group_names) : toset([])
  name                 = "rg-daily-cost-spike-${each.value}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = ["/subscriptions/${local.target_subscription_id}/resourceGroups/${each.value}"]
  severity             = 1
  description          = "Alert when resource group ${each.value} daily cost exceeds ${var.resource_group_daily_cost_threshold} USD"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceGroup == "${each.value}"
      | where CategoryValue == "Administrative"
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "write" or OperationNameValue contains "create"
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
    alert_type = "ResourceGroupDailyCost"
  })
}

# =======================================================================================
# RESOURCE GROUP ACTIVITY ALERTS
# =======================================================================================

# Resource Creation Spike Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_creation_spike" {
  for_each             = local.should_create_alerts && var.enable_resource_activity_alerts ? toset(var.resource_group_names) : toset([])
  name                 = "rg-resource-creation-spike-${each.value}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = ["/subscriptions/${local.target_subscription_id}/resourceGroups/${each.value}"]
  severity             = 2
  description          = "Alert when resource group ${each.value} has excessive resource creation activity (>${var.resource_creation_threshold} resources/day)"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceGroup == "${each.value}"
      | where CategoryValue == "Administrative"
      | where OperationNameValue contains "write" and ActivityStatusValue == "Success"
      | where OperationNameValue !contains "Microsoft.Authorization"
      | summarize ResourceCreations = count() by bin(TimeGenerated, 1h)
      | summarize DailyCreations = sum(ResourceCreations)
      | where DailyCreations > ${var.resource_creation_threshold}
    EOT
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  tags = merge(var.tags, {
    alert_type = "ResourceCreationSpike"
  })
}

# Resource Deletion Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_deletion_alert" {
  for_each             = local.should_create_alerts && var.enable_resource_activity_alerts ? toset(var.resource_group_names) : toset([])
  name                 = "rg-resource-deletion-alert-${each.value}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = ["/subscriptions/${local.target_subscription_id}/resourceGroups/${each.value}"]
  severity             = 2
  description          = "Alert when resource group ${each.value} has significant resource deletion activity (>${var.resource_deletion_threshold} deletions/day)"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(1d)
      | where ResourceGroup == "${each.value}"
      | where CategoryValue == "Administrative"
      | where OperationNameValue contains "delete" and ActivityStatusValue == "Success"
      | summarize ResourceDeletions = count() by bin(TimeGenerated, 1h)
      | summarize DailyDeletions = sum(ResourceDeletions)
      | where DailyDeletions > ${var.resource_deletion_threshold}
    EOT
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.action_group.id]
  }

  tags = merge(var.tags, {
    alert_type = "ResourceDeletion"
  })
}

# =======================================================================================
# COST TREND AND ANOMALY ALERTS
# =======================================================================================

# Idle Resources Alert - Resource Group Level
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "rg_idle_resources" {
  for_each             = local.should_create_alerts && var.enable_resource_group_trend_alerts ? toset(var.resource_group_names) : toset([])
  name                 = "rg-idle-resources-${each.value}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = var.evaluation_frequency_daily
  window_duration      = var.window_duration_daily
  scopes               = ["/subscriptions/${local.target_subscription_id}/resourceGroups/${each.value}"]
  severity             = 3
  description          = "Alert for potentially idle resources in resource group ${each.value}"

  criteria {
    query                   = <<-EOT
      AzureActivity
      | where TimeGenerated >= ago(7d)
      | where ResourceGroup == "${each.value}"
      | where ResourceProviderValue in ("Microsoft.Compute", "Microsoft.Storage")
      | where ActivityStatusValue == "Success"
      | where OperationNameValue contains "deallocate" or OperationNameValue contains "stop"
      | summarize IdleActivity = count() by ResourceId
      | where IdleActivity > 0
      | summarize TotalIdle = count()
      | where TotalIdle > 2
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
    alert_type = "IdleResources"
  })
}