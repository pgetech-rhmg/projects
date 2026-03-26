# Variables for user
variable "authentication_type" {
  description = "Authentication type for the user. You must specify USERPOOL."
  type        = string
  validation {
    condition     = can(regex("(API|SAML|USERPOOL)", var.authentication_type))
    error_message = "Invalid authentication type. Valis options are API, SAML, USERPOOL."
  }
}

variable "user_name" {
  description = "Email address of the user."
  type        = string
  validation {
    condition     = can(regex("([a-zA-Z0-9]@[pge]+.com)$", var.user_name))
    error_message = "Invalid email address format."
  }
}

variable "first_name" {
  description = "First name, or given name, of the user."
  type        = string
  default     = null
  validation {
    condition     = can(regex("([a-zA-Z0-9_-])$", var.first_name))
    error_message = "Allowed characters: a-Z,0-9,-_ ."
  }
}

variable "last_name" {
  description = "Last name, or surname, of the user."
  type        = string
  default     = null
  validation {
    condition     = can(regex("([a-zA-Z0-9_-])$", var.last_name))
    error_message = "Allowed characters: a-Z,0-9,-_ ."
  }
}

variable "enabled_user" {
  description = "Specifies whether the user in the user pool is enabled."
  type        = bool
  default     = true
}

variable "send_email_notification" {
  description = "Send an email notification."
  type        = bool
  default     = false
}