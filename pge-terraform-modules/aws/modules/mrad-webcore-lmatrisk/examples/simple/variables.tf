variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be created"
}

variable "create_lmatrisk" {
  description = "Whether to create a Lambda instance"
  type        = bool
  default     = false
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)"
}

variable "app_id" {
  type        = string
  description = "The application identifier"
}

variable "data_classification" {
  type        = string
  description = "The classification level of the data (e.g., public, confidential)"
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

variable "prefix" {
  description = "value to prepend to all resource names"
  type        = string
}

variable "git_branch" {
  description = "branch used to create the Lambda"
  type        = string
}

variable "node_env" {
  description = "The NODE_ENV to set in the build environment"
  type        = string
}

variable "suffix" {
  description = "The suffix for naming the resources"
  type        = string
}