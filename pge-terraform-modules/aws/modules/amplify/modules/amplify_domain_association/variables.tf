# Variables for Amplify Domain Association

variable "app_id" {
  description = "Unique ID for an Amplify app."
  type        = string
}

variable "domain_name" {
  description = "Domain name for the domain association."
  type        = string
  validation {
    condition     = alltrue([can(regex("$*.pge.com", var.domain_name))])
    error_message = "Error! Provide a valid PGE domain only."
  }
}

variable "sub_domain" {
  description = "Setting for the subdomain."
  type        = list(map(string))
}
/*
variable "branch_name" {
  description = "Branch name setting for the subdomain."
  type        = string
}

variable "prefix" {
  description = "Prefix setting for the subdomain."
  type        = string
}*/

variable "wait_for_verification" {
  description = "If enabled, the resource will wait for the domain association status to change to PENDING_DEPLOYMENT or AVAILABLE. Setting this to false will skip the process. Default: true."
  type        = bool
  default     = true
}
