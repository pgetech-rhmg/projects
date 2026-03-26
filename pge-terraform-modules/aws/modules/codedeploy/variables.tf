#Variable for aws_codedeploy_app
variable "codedeploy_app_name" {
  description = "The name of the application."
  type        = string
}

#The variable codedeploy_app_compute_platform can only take ECS, Lambda, or Server as the valid input values.
#The default value is Server.
variable "codedeploy_app_compute_platform" {
  description = "The compute platform can either be ECS, Lambda, or Server"
  type        = string
  default     = "Server"
  validation {
    condition     = contains(["ECS", "Lambda", "Server"], var.codedeploy_app_compute_platform)
    error_message = "Error! Please enter a valid value for codedeploy_app_compute_platform. Valid values are ECS, Lambda, or Server ."
  }
}

#Variable for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}