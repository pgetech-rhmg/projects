variable "file_system_id" {
  description = "The ID of the file system to back up."
  type        = string
  validation {
    condition     = can(regex("^fs-\\w+", var.file_system_id))
    error_message = "Error! enter a valid file_system_id."
  }
}

variable "timeouts" {
  description = "aws_fsx_backup provides the following Timeouts configuration options: create & delete."
  type        = map(string)
  default     = {}
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