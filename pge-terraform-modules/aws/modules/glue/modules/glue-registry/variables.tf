#Variables for tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for glue registry
variable "glue_registry_name" {
  description = "The Name of the registry."
  type        = string
}

variable "glue_registry_description" {
  description = "A description of the registry."
  type        = string
  default     = null
}