# Outputs for Action Groups Examples

# Production outputs
output "production_action_group_ids" {
  description = "Production action group IDs"
  value       = module.action_groups_production.action_group_ids
}

output "production_action_group_names" {
  description = "Production action group names"
  value       = module.action_groups_production.action_group_names
}

# Development outputs
output "dev_action_group_ids" {
  description = "Development action group IDs"
  value       = module.action_groups_dev.action_group_ids
}

# Regional outputs
output "regional_action_group_ids" {
  description = "Regional action group IDs"
  value       = module.action_groups_regional.action_group_ids
}

output "regional_action_group_details" {
  description = "Complete details of regional action groups"
  value       = module.action_groups_regional.action_group_details
}
