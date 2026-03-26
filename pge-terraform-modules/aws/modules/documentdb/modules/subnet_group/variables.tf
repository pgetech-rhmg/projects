#Variables for subnet group
variable "subnet_group_name" {
  description = "The name of the docDB subnet group."
  type        = string
}

variable "subnet_group_subnet_ids" {
  description = "A list of VPC subnet IDs. Subnet groups must contain at least two subnets in two different Availability Zones in the same AWS Region."
  type        = list(string)
  validation {
    condition = alltrue([
      for i in var.subnet_group_subnet_ids : can(regex("^subnet-\\w+", i))
    ])
    error_message = "The subnet id must be valid in form of 'subnet-xxxxxxx'."
  }
  validation {
    condition = alltrue([
      length(var.subnet_group_subnet_ids) >= 2
    ])
    error_message = "Error! Subnet groups must contain at least two subnets."
  }
}

variable "subnet_group_description" {
  description = "The description of the docDB subnet group. Defaults to Managed by Terraform."
  type        = string
  default     = null
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}