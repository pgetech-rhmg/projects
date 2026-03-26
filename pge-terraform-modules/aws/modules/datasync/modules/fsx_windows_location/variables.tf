variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "filesystem_arn" {
  description = "The ARN of the FSx Windows File System"
  type        = string
}

variable "user" {
  description = "The username to access the FSx Windows File System"
  type        = string
}

variable "password" {
  description = "The password to access the FSx Windows File System"
  type        = string
}

variable "security_group_arns" {
  description = "The ARNs of the security groups to associate with the FSx Windows File System. TF docs show this as optional, but it is required."
  type        = list(string)
}

variable "subdirectory" {
  description = "The subdirectory in the FSx Windows File System"
  type        = string
  default     = null
}

variable "domain" {
  description = "The domain of the FSx Windows File System"
  type        = string
  default     = null
}