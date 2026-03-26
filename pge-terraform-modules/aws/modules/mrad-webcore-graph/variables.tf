variable "suffix" {
  description = "Appended to all resource names"
  type        = string
}

variable "node_env" {
  description = "The node environment to load the configuration for"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "neptune_db_cluster_port" {
  description = "Neptune DB cluster port"
  type        = string
  default     = "8182"
}

variable "repo_branch" {
  type        = string
  description = "The branch from which the Engage-Graph code will be deployed"
}

variable "aws_role" {
  description = "value of the role to assume"
  type        = string
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "engage"
}

variable "project_name" {
  description = "Name of the github project"
  type        = string
  default     = "Engage-Graph"
}

variable "poller_ids" {
  description = "List of poller IDs to create. Each ID creates a different service"
  type        = list(string)
}