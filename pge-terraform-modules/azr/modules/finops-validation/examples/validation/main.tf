#
# Filename    : examples/validation/main.tf
# Description : Example usage of the FinOps Validation module
#

module "finops_validation" {
  source             = "../.."
  finops_csv_content = var.finops_csv_content
  partner_configs    = var.partner_configs
}
