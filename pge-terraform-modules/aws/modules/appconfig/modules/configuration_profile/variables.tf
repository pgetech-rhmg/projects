variable "name" {
  description = "The name of the AppConfig Configuration Profile name."
  type        = string
}

variable "description" {
  description = "The description of the AppConfig Configuration Profile description."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias."
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "application_id" {
  description = "An application_id to associate the profile with"
  type        = string
}