# Outputs for Azure Monitor Action Groups Module

output "action_group_ids" {
  description = "Map of action group names to their resource IDs"
  value       = { for k, v in azurerm_monitor_action_group.action_groups : v.name => v.id }
}

output "action_group_names" {
  description = "List of created action group names"
  value       = [for ag in azurerm_monitor_action_group.action_groups : ag.name]
}

output "action_group_short_names" {
  description = "Map of action group names to their short names"
  value       = { for k, v in azurerm_monitor_action_group.action_groups : v.name => v.short_name }
}

output "action_group_details" {
  description = "Complete details of all action groups"
  value = {
    for k, v in azurerm_monitor_action_group.action_groups : v.name => {
      id         = v.id
      short_name = v.short_name
      enabled    = v.enabled
      location   = v.location
    }
  }
}
