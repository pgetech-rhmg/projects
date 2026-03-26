variable "aws_region" {
  type = string
}

variable "create_lmnlbman" {
  description = "Whether to create a Lambda instance"
  type        = bool
  default     = false
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

variable "github_token" {
  type      = string
  sensitive = true
}

variable "account_num_r53" {
  type = string
}

variable "aws_r53_role" {
  type = string
}

variable "node_env" {
  description = "The NODE_ENV to set in the build environment"
  type        = string
}

variable "suffix" {
  description = "The suffix for naming the resources"
  type        = string
}