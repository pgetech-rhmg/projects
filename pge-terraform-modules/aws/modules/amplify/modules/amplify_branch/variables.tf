# Variables for Amplify

variable "app_id" {
  description = "Unique ID for an Amplify app."
  type        = string
}

variable "branch_name" {
  description = " Name for the branch."
  type        = string
}

variable "backend_environment_arn" {
  description = "ARN for a backend environment that is part of an Amplify app."
  type        = string
  default     = null
}

variable "basic_auth_credentials" {
  description = "Basic authorization credentials for the branch."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the branch."
  type        = string
  default     = null
}

variable "display_name" {
  description = "Display name for a branch. This is used as the default domain prefix."
  type        = string
  default     = null
}

variable "enable_auto_build" {
  description = "Enables auto building for the branch."
  type        = string
  default     = null
}

variable "enable_basic_auth" {
  description = "Enables basic authorization for the branch."
  type        = string
  default     = null
}

variable "enable_notification" {
  description = "Enables notifications for the branch."
  type        = string
  default     = null
}

variable "enable_performance_mode" {
  description = "Enables performance mode for the branch."
  type        = bool
  default     = null
}

variable "enable_pull_request_preview" {
  description = "Enables pull request previews for this branch."
  type        = bool
  default     = null
}

variable "environment_variables" {
  description = "Environment variables for the branch."
  type        = map(string)
  default     = null
}

variable "framework" {
  description = "Framework for the branch."
  type        = string
  default     = null
}

variable "pull_request_environment_name" {
  description = "Amplify environment name for the pull request."
  type        = string
  default     = null
}

variable "stage" {
  description = "Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
  default     = null
  validation {
    condition     = var.stage != null ? contains(["PRODUCTION", "BETA", "DEVELOPMENT", "EXPERIMENTAL", "PULL_REQUEST"], var.stage) : true
    error_message = "Error! Valid Values for amplify_branch_stage- Valid values are : PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST and null.!"
  }
}

variable "ttl" {
  description = "Content Time To Live (TTL) for the website in seconds."
  type        = number
  default     = null
}

# Variables for tags

variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.1"
  tags    = var.tags
}