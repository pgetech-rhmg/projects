variable "name" {
  description = " Unique name for the this Application Version."
  type        = string
}

variable "application" {
  description = "Name of the Beanstalk Application the version is associated with."
  type        = string
}

variable "bucket" {
  description = " S3 bucket that contains the Application Version source bundle."
  type        = string
}

variable "key" {
  description = "S3 object that is the Application Version source bundle."
  type        = string
}

variable "description" {
  description = "Short description of the Application Version."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "On delete, force an Application Version to be deleted when it may be in use by multiple Elastic Beanstalk Environments."
  type        = bool
  default     = false
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}