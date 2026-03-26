variable "aws_region" {
  type = string
}

variable "create_queries_pipeline" {
  description = "Whether to create the queries pipeline"
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

# queries repository identifiers
variable "queries_repo_name" {
  type = string
}

variable "queries_repo_org" {
  type        = string
  description = "The github organization that the queries repo belongs to. Must be one of pgetech or PGEDigitalCatalyst"

  validation {
    condition = anytrue([
      var.queries_repo_org == "pgetech",
      var.queries_repo_org == "PGEDigitalCatalyst"
    ])
    error_message = "The queries_repo_org variable must be one of pgetech or PGEDigitalCatalyst"
  }
}

variable "git_branch" {
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

variable "prefix" {
  type        = string
  description = "The prefix to use for the pipeline name"
}

variable "node_env" {
  description = "The node environment to use for the pipeline"
  type        = string
}
