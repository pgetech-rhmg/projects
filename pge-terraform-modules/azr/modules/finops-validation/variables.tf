/*
 * # FinOps Validation module - Variables
 * Terraform module which validates partner configurations against FinOps CSV data
*/
#
# Filename    : modules/finops_validation/variables.tf
# Date        : 11 Mar 2026
# Author      : PGE
# Description : Input variables for the FinOps validation module.
#

variable "partner_configs" {
  description = "Map of partner configs to validate. Must include subscription_name, tags.AppID and tags.Order."
  type        = any
}

variable "finops_csv_content" {
  description = "Raw contents of the FinOps CSV file."
  type        = string
  default     = ""
}
