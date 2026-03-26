#Variables for transfer family workflow
variable "description" {
  description = "A textual description for the workflow."
  type        = string
  default     = null
}

variable "on_exception_steps" {
  description = "Specifies the steps (actions) to take if errors are encountered during execution of the workflow."
  #The variable 'on_exception_steps' have elements of different types and hence we have to use type 'list(any)'. The variable on_exception_steps is list, since it is able to call multiple times.
  type    = any
  default = []

  validation {
    condition     = alltrue(flatten([for vi in var.on_exception_steps : [for kj, vj in vi : contains(["COPY", "CUSTOM", "DELETE", "TAG"], vj) if kj == "type"]]))
    error_message = "Error! enter a valid value for type."
  }
}

variable "steps" {
  description = "Specifies the details for the steps that are in the specified workflow."
  #The variable 'steps' have elements of different types and hence we have to use type 'list(any)'. The variable steps is list, since it is able to call multiple times.
  type    = any
  default = []
  validation {
    condition     = alltrue(flatten([for vi in var.steps : [for kj, vj in vi : contains(["COPY", "CUSTOM", "DELETE", "TAG"], vj) if kj == "type"]]))
    error_message = "Error! enter a valid value for type."
  }
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
