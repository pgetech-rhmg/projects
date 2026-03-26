/*
 * # FinOps Validation module - Outputs
 * Terraform module which validates partner configurations against FinOps CSV data
*/
#
# Filename    : modules/finops_validation/outputs.tf
# Date        : 11 Mar 2026
# Author      : PGE
# Description : Output values for the FinOps validation module.
#

output "approved_partner_configs" {
  description = "Map of partners approved for vending (AppID and Order# match CSV)"
  value       = local.approved_partner_configs
}

output "finops_validation_status" {
  description = "Status for each partner: AppID, Order#, approved (true/false)"
  value       = local.finops_validation_status
}

output "finops_mismatches" {
  description = "List of partners not approved, with reason."
  value       = local.finops_mismatches
}
