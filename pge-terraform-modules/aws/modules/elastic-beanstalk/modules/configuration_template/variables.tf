#Variables for configuration template
variable "template_name" {
  description = "A unique name for this Template."
  type        = string
}

variable "application" {
  description = "Name of the application to associate with this configuration template."
  type        = string
}

variable "description" {
  description = "Short description of the Template."
  type        = string
  default     = null
}

variable "environment_id" {
  description = "The ID of the environment used with this configuration template."
  type        = string
  default     = null
}

variable "setting" {
  description = "Option settings to configure the new Environment. These override specific values that are set as defaults."
  type = list(object({
    namespace = string
    name      = string
    value     = string
    resource  = optional(string)
  }))
  default = []
}

variable "solution_stack_name" {
  description = "A solution stack to base your Template off of."
  type        = string
  default     = null
}