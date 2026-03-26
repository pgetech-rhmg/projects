variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "repo_name" {
  description = "The name of the lambda repository to deploy."
  type        = string
}

variable "repo_branch" {
  description = "The branch of the repository to deploy."
  type        = string
}

variable "suffix" {
  description = "The suffix to append to resource names, typically representing the deployment environment or branch."
  type        = string
}

variable "node_env" {
  description = "The Node.js environment (e.g., dev, qa, production)."
  type        = string
}

variable "short_name" {
  description = "The short name of the lambda. Used for resource naming and identification."
  type        = string
}

variable "prefix" {
  description = "The prefix to prepend to resource names, typically representing the project or team."
  type        = string
  default     = "engage"
}