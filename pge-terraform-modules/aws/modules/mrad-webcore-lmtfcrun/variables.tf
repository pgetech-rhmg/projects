variable "tags" {
  description = "A map of tags passed in during deployment"
  type        = map(any)
}

variable "git_branch" {
  description = "The git branch of the TFC configuration"
  type        = string
}

variable "prefix" {
  description = "The prefix for the resources"
  type        = string
  default     = "engage"
}
