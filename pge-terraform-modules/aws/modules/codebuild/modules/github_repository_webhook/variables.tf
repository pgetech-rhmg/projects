variable "github_token" {
  description = "ARN of the GitHub Secrets Manager containing the OAUTH or PAT"
  type        = string
}

variable "github_base_url" {
  description = "GitHub target API endpoint"
  type        = string
  validation {
    condition     = can(regex("^(https://).+(.com/)$", var.github_base_url))
    error_message = "Error! enter a valid base url."
  }
}

variable "github_repository" {
  description = "The repository of the webhook"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.github_repository))
    error_message = "Error! The repository name must contains only alphabets, numbers and - ."
  }
}

variable "github_events" {
  description = "Indicate if the webhook should receive events"
  type        = list(string)
}

variable "github_content_type" {
  description = "The content type for the payload"
  type        = string
  validation {
    condition     = var.github_content_type == "form" || var.github_content_type == "json"
    error_message = "Valid values are form or json."
  }
}

variable "github_insecure_ssl" {
  description = "Insecure SSL boolean toggle"
  type        = bool
  default     = false
}

variable "github_name" {
  description = "The type of the webhook"
  type        = string
  default     = null
  validation {
    condition     = var.github_name == "web" || var.github_name == null
    error_message = "Web is the default and the only option."
  }
}

variable "github_active" {
  description = "Indicate if the webhook should receive events"
  type        = bool
  default     = true
}

#variables for aws_codebuild_webhook
variable "codebuild_webhook_project_name" {
  description = "The name of the build project."
  type        = string
}

variable "codebuild_webhook_build_type" {
  description = "The type of build this webhook will trigger"
  type        = string
  default     = null
  validation {
    condition     = var.codebuild_webhook_build_type == "BUILD" || var.codebuild_webhook_build_type == "BUILD_BATCH" || var.codebuild_webhook_build_type == null
    error_message = "Valid values for this parameter are: BUILD, BUILD_BATCH."
  }
}

variable "codebuild_webhook_branch_filter" {
  description = "A regular expression used to determine which branches get built. Default is all branches are built"
  type        = string
  default     = null
}

variable "filter" {
  description = "List of nested attributes"
  type        = any
  default     = []
}
