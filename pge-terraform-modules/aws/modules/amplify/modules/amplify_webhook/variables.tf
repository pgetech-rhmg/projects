# Variables for Amplify Webhook

variable "app_id" {
  description = "Unique ID for an Amplify app."
  type        = string
}

variable "branch_name" {
  description = "Name for a branch that is part of the Amplify app."
  type        = string
}

variable "description" {
  description = "Description for a webhook."
  type        = string
  default     = null
}
