# Outputs for Azure Compute Gallery AMBA Alerts Module

output "alert_ids" {
  description = "Map of all activity log alert resource IDs"
  value = {
    gallery_creation            = length(azurerm_monitor_activity_log_alert.gallery_creation) > 0 ? azurerm_monitor_activity_log_alert.gallery_creation[0].id : null
    gallery_deletion            = length(azurerm_monitor_activity_log_alert.gallery_deletion) > 0 ? azurerm_monitor_activity_log_alert.gallery_deletion[0].id : null
    image_definition_operations = length(azurerm_monitor_activity_log_alert.image_definition_operations) > 0 ? azurerm_monitor_activity_log_alert.image_definition_operations[0].id : null
    image_version_operations    = length(azurerm_monitor_activity_log_alert.image_version_operations) > 0 ? azurerm_monitor_activity_log_alert.image_version_operations[0].id : null
    sharing_profile_changes     = length(azurerm_monitor_activity_log_alert.sharing_profile_changes) > 0 ? azurerm_monitor_activity_log_alert.sharing_profile_changes[0].id : null
    access_control_changes      = length(azurerm_monitor_activity_log_alert.access_control_changes) > 0 ? azurerm_monitor_activity_log_alert.access_control_changes[0].id : null
  }
}

output "alert_names" {
  description = "Map of all activity log alert names"
  value = {
    gallery_creation            = length(azurerm_monitor_activity_log_alert.gallery_creation) > 0 ? azurerm_monitor_activity_log_alert.gallery_creation[0].name : null
    gallery_deletion            = length(azurerm_monitor_activity_log_alert.gallery_deletion) > 0 ? azurerm_monitor_activity_log_alert.gallery_deletion[0].name : null
    image_definition_operations = length(azurerm_monitor_activity_log_alert.image_definition_operations) > 0 ? azurerm_monitor_activity_log_alert.image_definition_operations[0].name : null
    image_version_operations    = length(azurerm_monitor_activity_log_alert.image_version_operations) > 0 ? azurerm_monitor_activity_log_alert.image_version_operations[0].name : null
    sharing_profile_changes     = length(azurerm_monitor_activity_log_alert.sharing_profile_changes) > 0 ? azurerm_monitor_activity_log_alert.sharing_profile_changes[0].name : null
    access_control_changes      = length(azurerm_monitor_activity_log_alert.access_control_changes) > 0 ? azurerm_monitor_activity_log_alert.access_control_changes[0].name : null
  }
}

output "monitored_subscriptions" {
  description = "List of monitored subscription IDs"
  value       = var.subscription_ids
}

output "action_group_id" {
  description = "The ID of the Action Group used for alerts"
  value       = data.azurerm_monitor_action_group.action_group.id
}
