variable "aws_region" {
  description = "The AWS region where resources are created"
  type        = string
}

variable "create_graph" {
  description = "Whether to create a Graph instance"
  type        = bool
  default     = false
}

variable "suffix" {
  description = "Appended to resource names to prevent collisions"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Engage-Graph"
}

variable "environment" {
  description = "One of Dev, QA, or Prod"
  type        = string
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

variable "order" {
  type = string
}

variable "graph_repo_branch" {
  description = "The branch to use for the graph repo"
  type = string
}

variable "github_token" {
  description = "The GitHub token to use for the graph repo"
  type      = string
  sensitive = true
}

variable "workspace_name" {
  type = string
  description = "This is auto-populated from the tfc workspace"
}

variable "account_num_r53" {
  type = string
}

variable "aws_r53_role" {
  type = string
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "engagetest"
}
