# # Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "prefix_name" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = string
  default     = null
}

variable "secrets_description" {
  description = "Description of the secrets"
  type        = string
}

variable "custom_policy" {
  description = "Valid JSON document representing a resource policy"
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.custom_policy))
    error_message = "Error! Invalid JSON for custom policy. Provide a valid JSON for secrets manager."
  }
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30

  validation {
    condition = (
      var.recovery_window_in_days == 0 ||
      var.recovery_window_in_days >= 7 &&
    var.recovery_window_in_days <= 30)
    error_message = "Invalid value; recovery window value can be 0 to force deletion without recovery or range from 7 to 30 days."
  }
}

variable "kms_key_id" {
  description = "ARN or Id of the AWS KMS customer master key to encrypt secretsmanager"
  type        = string
  default     = null
}

variable "rotation_enabled" {
  description = "Specifies if rotation is set or not"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "Specifies the ARN of the Lambda function that can rotate the secret"
  type        = string
  default     = null
}

variable "rotation_after_days" {
  description = "A structure that defines the rotation configuration for this secret"
  type        = number
  default     = null
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
  default     = false
}

variable "secrets" {
  description = "Map of configuration keys to secret values"
  type        = map(string)
  default     = {}
}
