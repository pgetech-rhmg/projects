variable "aws_region" {
  type = string
}

variable "create_graph_pipeline" {
  description = "Whether to create the graph pipeline"
  type        = bool
  default     = false
}

variable "suffix" {
  description = "Appended to resource names to prevent collisions"
  type        = string
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

variable "order" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "prefix" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "engagetest"
}
