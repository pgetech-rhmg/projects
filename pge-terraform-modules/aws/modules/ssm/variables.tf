variable "name" {
  description = "Name of the parameter"
  type        = string
  validation {
    condition     = (length(var.name) > 0)
    error_message = "name can't be empty."
  }
}

variable "value" {
  description = "Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type."
  type        = string
  validation {
    condition     = (length(var.value) > 0)
    error_message = "value can't be empty."
  }
}

variable "description" {
  description = "Description of the parameter."
  default     = "AWS SSM Recource created by TFC "
  type        = string
}

variable "type" {
  description = "Type of the parameter. Valid types are String, StringList and SecureString."
  default     = "String"
  type        = string
  validation {
    condition     = (contains(["String", "StringList", "SecureString"], var.type))
    error_message = "expected type to be one of [String StringList SecureString]"
  }
}

variable "tier" {
  description = "Parameter tier to assign to the parameter. Valid tiers are Standard, Advanced, and Intelligent-Tiering"
  default     = "Standard"
  type        = string
}



variable "allowed_pattern" {
  description = "Regular expression used to validate the parameter value."
  default     = ""
  type        = string
}

variable "data_type" {
  description = "Data type of the parameter. Valid values: text and aws:ec2:image for AMI format, see the Native parameter support for Amazon Machine Image IDs."
  default     = "text"
  type        = string
}

variable "key_id" {
  description = "KMS key ID or ARN for encrypting a SecureString."
  default     = null
  type        = string
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

