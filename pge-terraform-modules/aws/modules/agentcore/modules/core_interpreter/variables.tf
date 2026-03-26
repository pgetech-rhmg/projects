# – Agent Core Code Interpreter Custom –

variable "create_code_interpreter" {
  description = "Whether or not to create an agent core code interpreter custom."
  type        = bool
  default     = false
}

variable "code_interpreter_name" {
  description = "The name of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, _ (underscore). The name must start with a letter and can be up to 48 characters long."
  type        = string
  default     = "TerraformBedrockAgentCoreCodeInterpreter"

  validation {
    condition     = length(var.code_interpreter_name) >= 1 && length(var.code_interpreter_name) <= 48
    error_message = "The code_interpreter_name must be between 1 and 48 characters in length."
  }

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.code_interpreter_name))
    error_message = "The code_interpreter_name must start with a letter and can only include letters, numbers, and underscores."
  }
}

variable "code_interpreter_description" {
  description = "Description of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, _ (underscore), - (hyphen) and spaces. The description can have up to 200 characters."
  type        = string
  default     = null

  validation {
    condition     = var.code_interpreter_description == null || try(length(var.code_interpreter_description) <= 200, true)
    error_message = "The code_interpreter_description must be 200 characters or less."
  }

  validation {
    condition     = var.code_interpreter_description == null || try(can(regex("^[a-zA-Z0-9_\\- ]*$", var.code_interpreter_description)), true)
    error_message = "The code_interpreter_description can only include letters, numbers, underscores, hyphens, and spaces."
  }
}

variable "code_interpreter_role_arn" {
  description = "Optional external IAM role ARN for the Bedrock agent core code interpreter. If empty, the module will create one internally."
  type        = string
  default     = null
}

variable "code_interpreter_network_mode" {
  description = "Network mode configuration type for the agent core code interpreter. Valid values: SANDBOX, VPC."
  type        = string
  default     = "SANDBOX"

  validation {
    condition     = contains(["SANDBOX", "VPC"], var.code_interpreter_network_mode)
    error_message = "The code_interpreter_network_mode must be either SANDBOX or VPC."
  }
}

variable "code_interpreter_network_configuration" {
  description = "VPC network configuration for the agent core code interpreter."
  type = object({
    security_groups = optional(list(string))
    subnets         = optional(list(string))
  })
  default = null
}

variable "code_interpreter_tags" {
  description = "A map of tag keys and values for the agent core code interpreter. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: _ . : / = + @ -"
  type        = map(string)
  default     = null

  validation {
    condition = var.code_interpreter_tags == null || alltrue(try([
      for k, v in var.code_interpreter_tags :
      length(k) >= 1 && length(k) <= 256 &&
      length(v) >= 1 && length(v) <= 256
    ], [true]))
    error_message = "Each tag key and value must be between 1 and 256 characters in length."
  }

  validation {
    condition = var.code_interpreter_tags == null || alltrue(try([
      for k, v in var.code_interpreter_tags :
      can(regex("^[a-zA-Z0-9\\s._:/=+@-]*$", k)) &&
      can(regex("^[a-zA-Z0-9\\s._:/=+@-]*$", v))
    ], [true]))
    error_message = "Tag keys and values can only include alphanumeric characters, spaces, and the following special characters: _ . : / = + @ -"
  }
}

# - IAM -
variable "permissions_boundary_arn" {
  description = "The ARN of the IAM permission boundary for the role."
  type        = string
  default     = null
}