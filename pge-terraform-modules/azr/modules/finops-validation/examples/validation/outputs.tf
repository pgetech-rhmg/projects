#
# Filename    : examples/validation/outputs.tf
# Description : Output values from the FinOps Validation example
#

output "approved_partner_configs" {
  description = "Map of partners approved for vending"
  value       = module.finops_validation.approved_partner_configs
}

output "finops_validation_status" {
  description = "Validation status for each partner"
  value       = module.finops_validation.finops_validation_status
}

output "finops_mismatches" {
  description = "List of partners with validation mismatches"
  value       = module.finops_validation.finops_mismatches
}
