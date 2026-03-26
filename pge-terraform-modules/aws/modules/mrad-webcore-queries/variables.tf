variable "application_port" {
  type        = string
  description = "The port or ports that the application exposes"
  default     = "5000"
}

variable "health_check_path" {
  type        = string
  description = "Path for health check"
  default     = "/graphql"
}

variable "suffix" {
  type        = string
  description = "Appended to all resources created by Terraform"
}

variable "git_branch" {
  type        = string
  description = "Used to determine the commit hash for the ECS task definition"
}

variable "region" {
  type        = string
  description = "The AWS region in which our project is deployed"
  default     = "us-west-2"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
}

variable "workspace_name" {
  type        = string
  description = "Current workspace name"
}

variable "prefix" {
  type        = string
  description = "The prefix to use for all resources"
  default     = "engage"
}

variable "short_name" {
  type        = string
  description = "A short name for the application"
  default     = "queries"
}

variable "node_env" {
  description = "The node environment to use for the pipeline"
  type        = string
}
