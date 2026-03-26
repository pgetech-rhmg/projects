variable "aws_region" {
  type = string
}

variable "create_queries" {
  description = "Whether to create a Queries instance"
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
# variable "queries_repo_name" {
#   type = string
# }

# variable "queries_repo_org" {
#   type        = string
#   description = "The github organization that the queries repo belongs to. Must be one of pgetech or PGEDigitalCatalyst"

#   validation {
#     condition = anytrue([
#       var.queries_repo_org == "pgetech",
#       var.queries_repo_org == "PGEDigitalCatalyst"
#     ])
#     error_message = "The queries_repo_org variable must be one of pgetech or PGEDigitalCatalyst"
#   }
# }

variable "queries_repo_branch" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "workspace_name" {
  type = string
}

variable "account_num_r53" {
  type = string
}

variable "aws_r53_role" {
  type = string
}

variable "prefix" {
  type        = string
  description = "The prefix to use for all resources"
  default     = "engage"
}
