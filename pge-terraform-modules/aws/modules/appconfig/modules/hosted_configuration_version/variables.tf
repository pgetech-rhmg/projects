variable "description" {
  description = "The description of the AppConfig Configuration Profile description."
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

variable "configuration_profile_id" {
  description = "The ID of the configuration profile to associate this resource with."
  type        = string
}

variable "application_id" {
  description = "An application_id to associate the profile with"
  type        = string
}

variable "content" {
  description = "Content of the configuration data"
  type        = string
}

variable "content_type" {
  description = "Standard MIME type describing the format of the configuration content."
  type        = string
  default     = "application/json"
}
