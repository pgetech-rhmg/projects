variable "aws_region" {
  type = string
}

variable "create_webapp_pipeline" {
  description = "Whether to create the webapp pipeline"
  type        = bool
  default     = false
}

variable "suffix" {
  description = "Appended to resource names to prevent collisions"
  type        = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "app_id" {
  type = string
}

variable "data_classification" {
  type = string
}

variable "cris" {
  type = string
}

variable "notify" {
  type = list(string)
}

variable "owner" {
  type = list(string)
}

variable "compliance" {
  type = list(string)
}

# webapp repository identifiers
variable "webapp_repo_name" {
  type = string
}

variable "webapp_repo_org" {
  type        = string
  description = "The github organization that the webapp repo belongs to. Must be one of pgetech or PGEDigitalCatalyst"

  validation {
    condition = anytrue([
      var.webapp_repo_org == "pgetech",
      var.webapp_repo_org == "PGEDigitalCatalyst"
    ])
    error_message = "The webapp_repo_org variable must be one of pgetech or PGEDigitalCatalyst"
  }
}

variable "webapp_repo_branch" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "target_workspace" {
  type        = string
  description = "The workspace resources that this pipeline will deploy into"
}

variable "create_viewer_pipeline" {
  description = "Whether to create the viewer pipeline"
  type        = bool
  default     = false
}

# viewer repository identifiers
variable "viewer_repo_name" {
  type = string
}

variable "viewer_repo_org" {
  type        = string
  description = "The github organization that the viewer repo belongs to. Must be one of pgetech or PGEDigitalCatalyst"

  validation {
    condition = anytrue([
      var.viewer_repo_org == "pgetech",
      var.viewer_repo_org == "PGEDigitalCatalyst"
    ])
    error_message = "The viewer_repo_org variable must be one of pgetech or PGEDigitalCatalyst"
  }
}

variable "viewer_repo_branch" {
  type = string
}