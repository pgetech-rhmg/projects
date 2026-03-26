output "policy_assignment_ids" {
  description = "List of policy assignment IDs"
  value = concat(
    [azurerm_subscription_policy_assignment.require_appid.id],
    [for k, v in azurerm_subscription_policy_assignment.require_tags : v.id],
    [azurerm_subscription_policy_assignment.allowed_locations.id],
    [azurerm_subscription_policy_assignment.audit_vm_managed_disks.id],
    [azurerm_subscription_policy_assignment.storage_secure_transfer.id]
  )
}

output "policy_assignment_names" {
  description = "List of policy assignment names"
  value = concat(
    [azurerm_subscription_policy_assignment.require_appid.display_name],
    [for k, v in azurerm_subscription_policy_assignment.require_tags : v.display_name],
    [azurerm_subscription_policy_assignment.allowed_locations.display_name],
    [azurerm_subscription_policy_assignment.audit_vm_managed_disks.display_name],
    [azurerm_subscription_policy_assignment.storage_secure_transfer.display_name]
  )
}

output "custom_policy_definition_id" {
  description = "Custom AppID policy definition ID"
  value       = azurerm_policy_definition.require_appid_tag.id
}