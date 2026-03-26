variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
  default     = null
}

variable "secretsmanager_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = string
  default     = null
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
}

variable "kms_key_id" {
  description = "ARN or Id of the AWS KMS customer master key to encrypt secretsmanager"
  type        = string
  default     = null
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

variable "replica_kms_key_id" {
  description = "ARN, Key ID, or Alias for encrypting secretsmanager replica"
  type        = string
  default     = null
}

variable "replica_region" {
  description = "Region for replicating the secret"
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of user-defined tags that are attached to the secret"
  type        = map(string)

}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
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

variable "secret_string" {
  description = "Specifies text data that you want to encrypt and store in this version of the secret"
  type        = string
  default     = null
}

variable "secret_binary" {
  description = "Specifies binary data that you want to encrypt and store in this version of the secret"
  type        = string
  default     = null
}

variable "version_stages" {
  description = "Specifies a list of staging labels that are attached to this version of the secret"
  type        = list(string)
  default     = null
}
