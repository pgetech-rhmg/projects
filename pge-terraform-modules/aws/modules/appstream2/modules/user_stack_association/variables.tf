variable "stack_name" {
  description = "Name of the stack that is associated with the user."
  type        = string
}

variable "authentication_type" {
  description = " Authentication type for the user."
  type        = string
  validation {
    condition     = can(regex("(API|SAML|USERPOOL)", var.authentication_type))
    error_message = "Invalid authentication type. Valis options are API, SAML, USERPOOL."
  }
}

variable "user_name" {
  description = "Email address of the user who is associated with the stack."
  type        = string
}

variable "send_email_notification" {
  description = "Specifies whether a welcome email is sent to a user after the user is created in the user pool."
  type        = bool
  default     = null
}