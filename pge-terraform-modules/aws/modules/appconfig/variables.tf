variable "tags" {
  description = "Key-value map of resource tags"
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

# Environments
variable "env_name" {
  description = "The name of the AppConfig environment."
  type        = string
}

variable "env_description" {
  description = "The description of the AppConfig environment."
  type        = string
  default     = null
}

variable "env_monitors" {
  description = "A map of monitors for your environment."
  type        = set(any)
  default     = []
}

# Application vars
variable "name" {
  description = "The name of the AppConfig application."
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the AppConfig application."
  type        = string
  default     = null
}

# Configuration profile vars
variable "config_profile_name" {
  description = "The name of the AppConfig configuration profile."
  type        = string
}

variable "config_profile_description" {
  description = "The description of the AppConfig configuration profile."
  type        = string
}

# Hosted Config content
variable "hosted_config_description" {
  description = "The description of the AppConfig Configuration Profile description."
  type        = string
  default     = null
}

variable "hosted_config_content" {
  description = "Content of the configuration data"
  type        = string
}

variable "hosted_config_content_type" {
  description = "Standard MIME type describing the format of the configuration content."
  type        = string
  default     = "application/json"
}
