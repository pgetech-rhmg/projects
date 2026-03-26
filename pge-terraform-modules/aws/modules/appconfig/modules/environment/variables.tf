variable "application_id" {
  description = "An application ID"
  type        = string
}

variable "monitors" {
  description = "A map of monitors for your deployment."
  type        = set(any)
  default     = []
}

variable "name" {
  description = "The name of the AppConfig application."
  type        = string
}

variable "description" {
  description = "The description of the AppConfig application."
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
