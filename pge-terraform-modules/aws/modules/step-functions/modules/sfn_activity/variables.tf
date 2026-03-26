variable "sfn_activity_name" {
  description = "The name of the activity to create."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.sfn_activity_name))
    error_message = "Error! Enter a valid sfn_activity_name. Must be 1-80 characters. Can use alphanumeric characters, dashes, or underscores."
  }
  validation {
    condition     = (length(var.sfn_activity_name) >= 1 && (length(var.sfn_activity_name) <= 80))
    error_message = "Error! sfn_activity_name must be 1-80 characters."
  }
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