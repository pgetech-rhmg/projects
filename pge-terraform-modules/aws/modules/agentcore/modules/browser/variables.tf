# – Agent Core Browser Custom –

variable "create_browser" {
  description = "Whether or not to create an agent core browser custom."
  type        = bool
  default     = false
}

variable "browser_name" {
  description = "The name of the agent core browser. Valid characters are a-z, A-Z, 0-9, _ (underscore). The name must start with a letter and can be up to 48 characters long."
  type        = string
  default     = "TerraformBedrockAgentCoreBrowser"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.browser_name))
    error_message = "The browser_name must start with a letter and can only include letters, numbers, and underscores, with a maximum length of 48 characters."
  }
}

variable "browser_description" {
  description = "Description of the agent core browser."
  type        = string
  default     = null
}

variable "browser_role_arn" {
  description = "Optional external IAM role ARN for the Bedrock agent core browser. If empty, the module will create one internally."
  type        = string
  default     = null
}

variable "browser_network_mode" {
  description = "Network mode configuration type for the agent core browser. Valid values: PUBLIC, VPC."
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.browser_network_mode)
    error_message = "The browser_network_mode must be either PUBLIC or VPC."
  }
}

variable "browser_network_configuration" {
  description = "VPC network configuration for the agent core browser. Required when browser_network_mode is set to 'VPC'."
  type = object({
    security_groups = optional(list(string))
    subnets         = optional(list(string))
  })
  default = null

  validation {
    condition     = var.browser_network_configuration == null || (try(length(coalesce(var.browser_network_configuration.security_groups, [])), 0) > 0 && try(length(coalesce(var.browser_network_configuration.subnets, [])), 0) > 0)
    error_message = "When providing browser_network_configuration, you must include at least one security group and one subnet."
  }
}

variable "browser_recording_enabled" {
  description = "Whether to enable browser session recording to S3."
  type        = bool
  default     = false
}

variable "browser_recording_config" {
  description = "Configuration for browser session recording when enabled. Bucket name must follow S3 naming conventions (lowercase alphanumeric characters, dots, and hyphens), between 3 and 63 characters, starting and ending with alphanumeric character."
  type = object({
    bucket = string
    prefix = string
  })
  default = null

  validation {
    condition     = var.browser_recording_config == null || try(can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.browser_recording_config.bucket)), false)
    error_message = "S3 bucket name must follow naming conventions: lowercase alphanumeric characters, dots and hyphens, 3-63 characters long, starting and ending with alphanumeric character."
  }

  validation {
    condition     = var.browser_recording_config == null || try(var.browser_recording_config.prefix != null, true)
    error_message = "When providing a recording configuration, the S3 prefix cannot be null."
  }
}

variable "browser_tags" {
  description = "A map of tag keys and values for the agent core browser. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: _ . : / = + @ -"
  type        = map(string)
  default     = null

  validation {
    condition = var.browser_tags == null || alltrue(try([
      for k, v in var.browser_tags :
      length(k) >= 1 && length(k) <= 256 &&
      length(v) >= 1 && length(v) <= 256
    ], [true]))
    error_message = "Each tag key and value must be between 1 and 256 characters in length."
  }

  validation {
    condition = var.browser_tags == null || alltrue(try([
      for k, v in var.browser_tags :
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

