# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the parameter."
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

# Required parameter inputs
variable "parameter_name" {
  description = "Final segment of the parameter path. Combined into /pge-epic/<app_name>/<environment>/<parameter_name> unless custom_name is provided."
  type        = string
}

variable "value" {
  description = "Parameter value. For SecureString this is encrypted at rest under kms_key_id."
  type        = string
  sensitive   = true
}

# Optional inputs
variable "custom_name" {
  description = "Full parameter path override. Takes precedence over the auto-derived name."
  type        = string
  default     = null
  nullable    = true
}

variable "description" {
  description = "Human-readable description of the parameter."
  type        = string
  default     = null
  nullable    = true
}

variable "type" {
  description = "Parameter type. Use String for non-secret config; SecureString is intentionally restricted (prefer epic-pipeline-module-aws-secretmanager for credentials)."
  type        = string
  default     = "String"

  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.type)
    error_message = "type must be one of: String, StringList, SecureString."
  }
}

variable "tier" {
  description = "Parameter tier. Standard supports values up to 4 KB and is free; Advanced supports up to 8 KB and policies."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "tier must be one of: Standard, Advanced, Intelligent-Tiering."
  }
}

variable "data_type" {
  description = "Data type. Use 'text' for plain values; 'aws:ec2:image' / 'aws:ssm:integration' for AWS-validated content."
  type        = string
  default     = "text"
}

variable "kms_key_id" {
  description = "KMS Key ARN or alias for SecureString encryption. Required if type is SecureString."
  type        = string
  default     = null
  nullable    = true
}

variable "allowed_pattern" {
  description = "Regex pattern the value must match. Enforced at write time."
  type        = string
  default     = null
  nullable    = true
}

variable "overwrite" {
  description = "If true, an existing parameter with the same name will be overwritten on apply."
  type        = bool
  default     = true
}
