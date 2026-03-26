variable "state_machine_definition" {
  description = "The Amazon States Language definition of the state machine."
  type        = string
  validation {
    condition     = can(jsondecode(var.state_machine_definition))
    error_message = "Error! Invalid JSON for state_machine_definition. Provide a valid JSON."
  }
}

variable "state_machine_name" {
  description = "The name of the state machine. To enable logging with CloudWatch Logs, the name should only contain 0-9, A-Z, a-z, - and _."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.state_machine_name))
    error_message = "Error! Enter a valid state_machine_name.The name should only contain 0-9, A-Z, a-z, - and _."
  }
}

variable "state_machine_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to use for this state machine."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.state_machine_role_arn))
    error_message = "Error! state_machine_role_arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "state_machine_type" {
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD."
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.state_machine_type)
    error_message = "Error! enter valid values for state_machine_type. valid values are STANDARD & EXPRESS."
  }
}

variable "include_execution_data" {
  description = "Determines whether execution data is included in your log. When set to false, data is excluded."
  type        = bool
  default     = true
}

variable "level" {
  description = "Defines which category of execution history events are logged. Valid values: ALL, ERROR & FATAL."
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ALL", "ERROR", "FATAL"], var.level)
    error_message = "Error! enter valid values for level. valid values are ALL, ERROR & FATAL."
  }
}

variable "log_destination" {
  description = "Amazon Resource Name (ARN) of a CloudWatch log group. Make sure the State Machine has the correct IAM policies for logging."
  type        = string
  validation {
    condition     = can(regex("arn:aws:logs:\\w+(?:-\\w+)+:[[:digit:]]{12}:log-group:([a-zA-Z0-9/])+(.*)$", var.log_destination))
    error_message = "Error! Enter a valid log_destination."
  }
}

variable "tracing_configuration_enabled" {
  description = "When set to true, AWS X-Ray tracing is enabled."
  type        = bool
  default     = false
}
variable "publish" {
  description = "Boolean flag to control whether to publish a version of the state machine during creation."
  type        = bool
  default     = false
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "kms_key_id" {
  description = "The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias."
  type        = string
  default     = null
}

variable "kms_key_type" {
  type        = string
  description = "The encryption option specified for the state machine"
  default     = "AWS_OWNED_KEY"
}
