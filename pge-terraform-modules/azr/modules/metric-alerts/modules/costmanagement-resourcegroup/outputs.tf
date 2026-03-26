# Output the IDs of all created budget and query alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_consumption_budget_resource_group.monthly_rg_budget : "monthly_budget_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_group_daily_cost_spike : "daily_cost_spike_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_creation_spike : "resource_creation_spike_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_deletion_alert : "resource_deletion_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.rg_idle_resources : "idle_resources_${k}" => v.id }
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    { for k, v in azurerm_consumption_budget_resource_group.monthly_rg_budget : "monthly_budget_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_group_daily_cost_spike : "daily_cost_spike_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_creation_spike : "resource_creation_spike_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.resource_deletion_alert : "resource_deletion_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.rg_idle_resources : "idle_resources_${k}" => v.name }
  )
}

# Output the monitored resource groups
output "monitored_resource_groups" {
  description = "List of resource group names being monitored for cost management"
  value       = var.resource_group_names
}

# Output the subscription ID
output "subscription_id" {
  description = "Subscription ID where the monitored resource groups are located"
  value       = local.target_subscription_id
}

# Output the action group ID
output "action_group_id" {
  description = "ID of the action group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}

# Output budget thresholds
output "budget_thresholds" {
  description = "Budget alert thresholds configuration"
  value = {
    monthly_cost_threshold    = var.resource_group_monthly_cost_threshold
    daily_cost_threshold      = var.resource_group_daily_cost_threshold
    alert_percentage_first    = var.budget_alert_percentage_first
    alert_percentage_second   = var.budget_alert_percentage_second
    alert_percentage_critical = var.budget_alert_percentage_critical
  }
}
