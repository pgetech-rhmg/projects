#tags
#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#git variables

variable "repo_name" {
  description = "Github repository to be integrated with webhook"
  type        = string
}

variable "github_webhook_events" {
  description = "Indicate Which events would you like to trigger this webhook"
  type        = list(string)
  default     = ["push"]
}

variable "github_webhook_content_type" {
  description = "The content type for the payload"
  type        = string
  default     = "json"
  validation {
    condition     = var.github_webhook_content_type == "form" || var.github_webhook_content_type == "json"
    error_message = "Valid values are form or json."
  }
}

#variables for aws_codepipeline
variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
}