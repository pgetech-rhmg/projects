variable "name" {
  description = "The name of the lifecycle configuration (must be unique)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "on_create" {
  description = "A shell script (base64-encoded) that runs only once when the SageMaker Notebook Instance is created."
  type        = string
  default     = null
  validation {
    condition     = can(base64encode(var.on_create))
    error_message = "Error! Invalid policy. Content must be base64 encoded."
  }
}

variable "on_start" {
  description = "A shell script (base64-encoded) that runs every time the SageMaker Notebook Instance is started including the time it's created."
  type        = string
  default     = null
  validation {
    condition     = can(base64encode(var.on_start))
    error_message = "Error! Invalid policy. Content must be base64 encoded."
  }
}