variable "aws_region" {
  type = string
}

variable "create_seed_pipeline" {
  description = "Whether to create the seed pipeline"
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

variable "target_workspace" {
  type        = string
  description = "The workspace resources that this pipeline will deploy into"
}

variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
  default     = "engagetest"
}
