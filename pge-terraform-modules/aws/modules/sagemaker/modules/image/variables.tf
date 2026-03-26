variable "image_name" {
  description = "The name of the image. Must be unique to your account."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.image_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, - (hyphen)."
  }
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of an IAM role that enables Amazon SageMaker to perform tasks on your behalf."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.role_arn))
    ])
    error_message = "Role arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "display_name" {
  description = "The display name of the image. When the image is added to a domain (must be unique to the domain)."
  type        = string
  default     = null
  validation {
    condition     = anytrue([can(length(var.display_name) <= 128) || var.display_name == null])
    error_message = "Allowed lenght of 'display_name' is 128 character max"
  }
}

variable "description" {
  description = "The description of the image."
  type        = string
  default     = null
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