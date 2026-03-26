#Description : Variables declared for Redshift Subnet group
variable "subnet_group_name" {
  description = "The name of the Redshift Subnet group."
  type        = string
}

variable "subnet_group_description" {
  description = "The description of the Redshift Subnet group"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "An array of VPC subnet IDs."
  type        = list(string)
  validation {
    condition = alltrue([
      length(var.subnet_ids) >= 1
    ])
    error_message = "Error! Subnet groups must contain at least one subnet."
  }
  validation {
    condition = alltrue([
      for i in var.subnet_ids : can(regex("^subnet-([a-zA-Z0-9])+(.*)$", i))
    ])
    error_message = "Subnet_ids required and the allowed format of 'subnet_ids' is subnet-#########."
  }
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}