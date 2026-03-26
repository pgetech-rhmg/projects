variable "tags" {
  description = "A map of tags passed in during deployment"
  type        = map(any)
}

variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
  default     = "engage"
}

variable "git_branch" {
  description = "The branch in the github repository"
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