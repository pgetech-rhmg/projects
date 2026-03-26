variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "s3_datasync_access_role" {
  description = "The ARN of the IAM role used to access the S3 bucket by DataSync"
  type        = string
}

variable "s3_location_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "s3_location_subdirectory" {
  description = "The subdirectory in the S3 bucket"
  type        = string
}

variable "s3_storage_class" {
  description = "The storage class of the S3 bucket"
  type        = string
  default     = null
}