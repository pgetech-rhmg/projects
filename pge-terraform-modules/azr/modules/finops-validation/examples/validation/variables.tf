#
# Filename    : examples/validation/variables.tf
# Description : Input variables for FinOps Validation example
#

variable "finops_csv_content" {
  description = "Raw contents of the FinOps CSV file"
  type        = string
  default     = ""
}

variable "partner_configs" {
  description = "Map of partner configurations to validate"
  type        = any
  default     = {}
}
