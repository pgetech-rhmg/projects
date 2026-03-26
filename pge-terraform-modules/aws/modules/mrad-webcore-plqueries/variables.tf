variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "repo_name" {
  type        = string
  description = "The queries repository to build and deploy"
}

variable "repo_org" {
  type        = string
  description = "The github organization that the queries repo belongs to. Must be one of pgetech or PGEDigitalCatalyst"
  validation {
    condition = anytrue([
      var.repo_org == "pgetech",
      var.repo_org == "PGEDigitalCatalyst"
    ])
    error_message = "The repo_org variable must be one of pgetech or PGEDigitalCatalyst"
  }
}

variable "git_branch" {
  type        = string
  description = "The branch of the queries repository to build and deploy"
}

variable "target" {
  type        = string
  description = "The workspace resources that this pipeline will deploy into"
}

variable "prefix" {
  type        = string
  description = "The prefix to use for the pipeline name"
}

variable "suffix" {
  description = "The suffix to use for resource names"
  type        = string
}

variable "node_env" {
  description = "The NODE_ENV to set in the build environment"
  type        = string
}

variable "short_name" {
  type        = string
  description = "A short name for the application"
  default     = "queries"
}