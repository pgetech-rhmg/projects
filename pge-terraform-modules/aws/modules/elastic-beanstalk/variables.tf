variable "name" {
  description = "The name of the application, must be unique within your account"
  type        = string
}

variable "description" {
  description = "Short description of the application"
  type        = string
  default     = null
}

variable "appversion_lifecycle" {
  description = <<-DOC
 service_role :
    The ARN of an IAM service role under which the application version is deleted. Elastic Beanstalk must have permission to assume this role.
 max_count :
    The maximum number of application versions to retain ('max_age_in_days' and 'max_count' cannot be enabled simultaneously.).
 max_age_in_days :  
    The number of days to retain an application version ('max_age_in_days' and 'max_count' cannot be enabled simultaneously.).
 delete_source_from_s3 : 
    Set to true to delete a version's source bundle from S3 when the application version is deleted.
  DOC
  type = object({
    service_role          = string
    max_count             = optional(number)
    max_age_in_days       = optional(number)
    delete_source_from_s3 = optional(bool)
  })
  default = {
    service_role          = null
    max_count             = null
    max_age_in_days       = null
    delete_source_from_s3 = true
  }
  validation {
    condition     = var.appversion_lifecycle.service_role != null ? can(regex("^arn:aws:iam::\\w+", var.appversion_lifecycle.service_role)) : true
    error_message = "Error! Please provide service role in form of arn:aws:iam::xxxxxx!"
  }
  validation {
    condition     = var.appversion_lifecycle.max_count != null && var.appversion_lifecycle.max_age_in_days != null ? false : true
    error_message = "Error! Only one of either max_count or max_age_in_days can be provided!"
  }
}

#variables for tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}