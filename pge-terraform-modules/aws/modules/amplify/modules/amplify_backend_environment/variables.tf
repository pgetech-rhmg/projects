# Variables for Amplify Backend Environment

variable "app_id" {
  description = "Unique ID for an Amplify app."
  type        = string
}

variable "environment_name" {
  description = "Name for the backend environment."
  type        = string
}

variable "deployment_artifacts" {
  description = "Name of deployment artifacts."
  type        = string
  default     = null
}

variable "stack_name" {
  description = "AWS CloudFormation stack name of a backend environment."
  type        = string
  default     = null
}