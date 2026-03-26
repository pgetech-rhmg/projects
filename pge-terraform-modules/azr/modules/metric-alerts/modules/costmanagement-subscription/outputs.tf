# Output the IDs of all created budget and query alert resources
output "alert_ids" {
  description = "Map of alert names to their resource IDs"
  value = merge(
    { for k, v in azurerm_consumption_budget_subscription.monthly_budget : "monthly_budget_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.subscription_daily_cost_spike : "daily_cost_spike_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.compute_cost_alert : "compute_cost_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.storage_cost_alert : "storage_cost_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.database_cost_alert : "database_cost_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.networking_cost_alert : "networking_cost_${k}" => v.id },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.unused_resources_cost : "unused_resources_${k}" => v.id }
  )
}

# Output the names of all created alerts
output "alert_names" {
  description = "Map of alert types to their resource names"
  value = merge(
    { for k, v in azurerm_consumption_budget_subscription.monthly_budget : "monthly_budget_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.subscription_daily_cost_spike : "daily_cost_spike_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.compute_cost_alert : "compute_cost_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.storage_cost_alert : "storage_cost_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.database_cost_alert : "database_cost_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.networking_cost_alert : "networking_cost_${k}" => v.name },
    { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.unused_resources_cost : "unused_resources_${k}" => v.name }
  )
}

# Output the monitored subscriptions
output "monitored_subscriptions" {
  description = "List of subscription IDs being monitored for cost management"
  value       = var.subscription_ids
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
    monthly_cost_threshold    = var.subscription_monthly_cost_threshold
    daily_cost_threshold      = var.subscription_daily_cost_threshold
    alert_percentage_first    = var.budget_alert_percentage_first
    alert_percentage_second   = var.budget_alert_percentage_second
    alert_percentage_critical = var.budget_alert_percentage_critical
  }
}

# Output service-specific cost thresholds
output "service_cost_thresholds" {
  description = "Service-specific cost thresholds configuration"
  value = {
    compute_cost_threshold    = var.compute_cost_threshold
    storage_cost_threshold    = var.storage_cost_threshold
    database_cost_threshold   = var.database_cost_threshold
    networking_cost_threshold = var.networking_cost_threshold
  }
}
