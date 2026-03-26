variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
  default     = "engage"
}

variable "suffix" {
  description = "The suffix to use for resource names"
  type        = string
}

variable "node_env" {
  description = "The NODE_ENV to set in the build environment"
  type        = string
}

variable "repo_branch" {
  description = "The branch of the repository to use for the build"
  type        = string
}

variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
  default     = "Engage-Graph"
}

variable "poller_ids" {
  description = "List of poller IDs to create. Each ID creates a different service"
  type        = list(string)
}
