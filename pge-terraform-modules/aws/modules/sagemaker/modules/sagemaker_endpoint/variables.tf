# variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# variables for endpoint
variable "name" {
  description = "The name of the endpoint. If omitted, Terraform will assign a random, unique name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,100}$", var.name))
    error_message = "Allowed alphanumeric characters: a-z, A-Z, 0-9, and - (hyphen)."
  }
  validation {
    condition     = anytrue([length(var.name) <= 63])
    error_message = "Maximum of 63 alphanumeric characters. Can include hyphens (-), but not spaces. Must be unique within your account in an AWS Region."
  }
}

variable "endpoint_config_name" {
  description = "The name of the endpoint configuration to use."
  type        = string
}

variable "deployment_config" {
  description = "The deployment configuration for an endpoint, which contains the desired deployment strategy and rollback configurations."
  type        = list(any)
  default     = []
  validation {
    condition     = alltrue(flatten([for val in var.deployment_config : [for ki, vi in val : [for kj, vj in vi : [for kl, vl in vj : vl >= 600 && vl <= 14400 if kl == "maximum_execution_timeout_in_seconds"]] if ki == "blue_green_update_policy"]]))
    error_message = "Error! Note that the timeout value should be larger than the total waiting time specified in termination_wait_in_seconds and wait_interval_in_seconds. Valid values are between 600 and 14400."
  }
  validation {
    condition     = alltrue(flatten([for val in var.deployment_config : [for ki, vi in val : [for kj, vj in vi : [for kl, vl in vj : vl >= 0 && vl <= 3600 if kl == "termination_wait_in_seconds"]] if ki == "blue_green_update_policy"]]))
    error_message = "Error! Valid values for termination_wait_in_seconds are between 0 and 3600."
  }
  validation {
    condition     = alltrue(flatten([for val in var.deployment_config : [for ki, vi in val : [for kj, vj in vi : [for kl, vl in vj : [for kg, vg in vl : [for ku, vu in vg : vu >= 0 && vu <= 3600 if ku == "wait_interval_in_seconds"]] if kl == "traffic_routing_configuration"]] if ki == "blue_green_update_policy"]]))
    error_message = "Error! Valid values for wait_interval_in_seconds are between 0 and 3600."
  }
  validation {
    condition     = alltrue(flatten([for val in var.deployment_config : [for ki, vi in val : [for kj, vj in vi : [for kl, vl in vj : [for kg, vg in vl : [for ku, vu in vg : contains(["ALL_AT_ONCE", "CANARY", "LINEAR"], vu) if ku == "type"]] if kl == "traffic_routing_configuration"]] if ki == "blue_green_update_policy"]]))
    error_message = "Error! Valid values for for traffic configuration types are ALL_AT_ONCE, CANARY, and LINEAR."
  }
}