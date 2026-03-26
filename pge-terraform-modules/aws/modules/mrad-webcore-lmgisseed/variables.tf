variable "tags" {
  description = "A map of tags passed in during deployment"
  type = map
}

variable "prefix" {
  description = "The prefix prepended to resource names"
  type        = string
  default     = "engage"
}

variable "git_branch" {
  description = "The git branch to deploy from"
  type        = string
}