variable "tags" {
  description = "A map of tags passed in during deployment"
  type        = map(any)
}

variable "prefix" {
  description = "The prefix for the resources"
  type        = string
  default     = "engage"
}

variable "git_branch" {
  description = "The branch in the github repository"
  type        = string
}

variable "node_env" {
  description = "The node environment to load the configuration for"
  type        = string
}

variable "suffix" {
  description = "The suffix for naming the resources"
  type        = string
}