# Variables for Amplify

variable "name" {
  description = "Name for an Amplify app."
  type        = string
}

variable "secretsmanager_github_access_token_secret_name" {
  description = "Enter the name of secrets manager for amplify personal access token."
  type        = string
}

variable "secretsmanager_basic_auth_cred_secret_name" {
  description = "Enter the name of secrets manager for basic auth crentials"
  type        = string
}

variable "auto_branch_creation_config" {

  description = <<-_EOT
    {
      build_spec                    : Build specification (build spec) for the autocreated branch.
      enable_auto_build             : Enables auto building for the autocreated branch.  
      enable_performance_mode       : Enables performance mode for the branch.
      enable_pull_request_preview   : Enables pull request previews for the autocreated branch.
      environment_variables         : Environment variables for the autocreated branch.
      framework                     : Framework for the autocreated branch.
      pull_request_environment_name : Amplify environment name for the pull request.
      stage                         : Describes the current stage for the autocreated branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST.
    }
    _EOT

  type = object({
    build_spec                    = string
    enable_auto_build             = bool
    enable_performance_mode       = bool
    enable_pull_request_preview   = bool
    environment_variables         = map(string)
    framework                     = string
    pull_request_environment_name = string
    stage                         = string
  })

  default = ({
    build_spec                    = null
    enable_auto_build             = null
    enable_performance_mode       = null
    enable_pull_request_preview   = null
    environment_variables         = null
    framework                     = null
    pull_request_environment_name = null
    stage                         = null
  })

  # For stage argument in the variable 'auto_branch_creation_config', the valid values are: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST.

  validation {
    condition     = var.auto_branch_creation_config.stage != null ? contains(["PRODUCTION", "BETA", "DEVELOPMENT", "EXPERIMENTAL", "PULL_REQUEST"], var.auto_branch_creation_config.stage) : true
    error_message = "Error! Enter a valid value for auto_branch_creation_config - stage. The values supported are PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  }
}

variable "auto_branch_creation_patterns" {
  description = "Automated branch creation glob patterns for an Amplify app."
  type        = list(string)
  default     = null
}

variable "build_spec" {
  description = "The build specification (build spec) for an Amplify app."
  type        = string
  default     = null
}

variable "custom_rule" {

  description = <<-_EOT
  Custom rewrite and redirect rules for an Amplify app.
  {
   condition : Condition for a URL rewrite or redirect rule, such as a country code.
   source    : Source pattern for a URL rewrite or redirect rule.
   status    : Status code for a URL rewrite or redirect rule. Valid values: 200, 301, 302, 404, 404-200.
   target    : Target pattern for a URL rewrite or redirect rule.
  }
  _EOT

  type = object({
    condition = string
    source    = string
    status    = string
    target    = string
  })

  default = ({
    condition = null
    source    = null
    status    = null
    target    = null
  })

  validation {
    condition     = var.custom_rule.status != null ? contains(["200", "301", "301", "404", "404-200"], var.custom_rule.status) : true
    error_message = "Error! Valid values for custom_rule Status : '200', '301', '301', '404', '404-200'.!"
  }

}

variable "description" {
  description = "Description for an Amplify app."
  type        = string
  default     = null
}

variable "enable_auto_branch_creation" {
  description = "Enables automated branch creation for an Amplify app."
  type        = bool
  default     = null
}

variable "enable_branch_auto_build" {
  description = "Enables auto-building of branches for the Amplify App."
  type        = bool
  default     = null
}

variable "enable_branch_auto_deletion" {
  description = "Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository."
  type        = bool
  default     = null
}

variable "environment_variables" {
  description = "Environment variables map for an Amplify app."
  type        = map(string)
  default     = null
}

variable "iam_service_role_arn" {
  description = "AWS Identity and Access Management (IAM) service role for an Amplify app."
  type        = string
  default     = null

  validation {
    condition     = var.iam_service_role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.iam_service_role_arn)) : true
    error_message = "Error! Please provide valid iam service role arn in form of 'arn:aws:iam::xxxx'!"
  }
}

variable "platform" {
  description = "Platform or framework for an Amplify app. Valid values: WEB."
  type        = string
  default     = "WEB"
  validation {
    condition     = contains(["WEB"], var.platform)
    error_message = "Error! Valid Values for amplify_app_platform should be WEB."
  }
}

variable "github_repository_name" {
  description = "Repository for an Amplify app. The github repository should be created under PGE organization."
  type        = string
}

# Variables for tags

variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}