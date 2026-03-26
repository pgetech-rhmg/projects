variable "aws_service_names" {
  description = "List of AWS Service Names for which service-linked roles will be created"
  type        = set(string)
}

variable "description" {
  description = "Description of the role"
  type        = string
  default     = "IAM Role created by pge_team = ccoe-tf-developers"
}

variable "custom_suffix" {
  description = "(Optional, forces new resource) Additional string appended to the role name. Not all AWS services support custom suffixes"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
