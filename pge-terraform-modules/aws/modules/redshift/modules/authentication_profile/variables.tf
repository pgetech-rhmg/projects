#Variables for Authentication profile
variable "authentication_profile_name" {
  description = "The name of the authentication profile."
  type        = string
}

variable "authentication_profile_content" {
  description = "Authentication profile policy file name"
  type        = string
  validation {
    condition     = can(jsondecode(var.authentication_profile_content))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON."
  }
}