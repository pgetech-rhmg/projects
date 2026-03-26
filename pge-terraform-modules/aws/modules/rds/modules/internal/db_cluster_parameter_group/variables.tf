variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the DB cluster parameter group."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the DB cluster parameter group. Defaults to 'Managed by Terraform'."
  type        = string
  default     = null
}

variable "family" {
  description = "The family of the DB cluster parameter group."
  type        = string
}

variable "parameters" {
  description = "A list of DB parameter maps to apply.  Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-cluster-parameters after initial creation of the group."
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}

