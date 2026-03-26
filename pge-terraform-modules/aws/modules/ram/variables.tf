variable "share_name" {
  description = "The name for the Ram share"
  type        = string
}

variable "allow_external_principals" {
  description = "Indicates list of allowed principals to be associated with the resource share "
  type        = bool
  default     = false
}

variable "permission_arns" {
  description = "List of RAM permission ARNs to be attached to resource share"
  type        = list(string)
  default     = []
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}
