variable "name" {
  description = " The name of the model (must be unique)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "execution_role_arn" {
  description = "A role that SageMaker can assume to access model artifacts and docker images for deployment."
  type        = string
}

variable "inference_execution_config" {
  description = "Specifies details of how containers in a multi-container endpoint are called."
  type        = any
  default     = {}
  validation {
    condition     = alltrue([for ki, vi in var.inference_execution_config : vi == "Serial" && vi == "Direct" if ki == "mode"])
    error_message = "Error! enter a valid value for inference_execution_config  - mode. The values supported are Serial,Direct ."
  }
}

variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from."
  type        = list(string)
  validation {
    condition = alltrue([
      for i in var.subnet_ids : can(regex("^subnet-\\w+", i))
    ])
    error_message = "The subnet id must be valid in form of 'subnet-xxxxxxx'."
  }
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces."
  type        = list(string)
  validation {
    condition     = alltrue([for sgi in var.security_group_ids : can(regex("^sg-\\w+", sgi))])
    error_message = "Error! Provide list of security_group_ids, value should be in form of 'sg-xxxxxxxx'!."
  }
}

variable "containers" {
  description = <<DOC
  primary_container:
  The primary docker image containing inference code that is used when the model is deployed for predictions. If not specified, the container argument is required.
  container:
  Specifies containers in the inference pipeline. If not specified, the primary_container argument is required.
  DOC
  type = object({
    primary_container = any
    container         = list(any)
  })
  default = {
    primary_container = {}
    container         = []
  }

  validation {
    condition     = var.containers.primary_container == {} && length(var.containers.container) > 0 || var.containers.primary_container != {} && length(var.containers.container) == 0
    error_message = "Error! Model cannot cofigure both primary_container and container at the same time."
  }

  validation {
    condition     = var.containers.primary_container == {} && length(var.containers.container) == 0 ? false : true
    error_message = "Error! Model need either primary_container or container"
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}