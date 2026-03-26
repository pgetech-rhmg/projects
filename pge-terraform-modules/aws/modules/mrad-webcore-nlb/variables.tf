variable "tags" {
  description = "A map of tags passed in during deployment"
  type        = map(any)
}

variable "repo_branch" {
  description = "The git branch to pull the code from"
  type        = string
}

variable "suffix" {
  description = "The suffix for naming the resources"
  type        = string
}

variable "prefix" {
  description = "The prefix for the resources"
  type        = string
  default     = "engage"
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "us-west-2"
}