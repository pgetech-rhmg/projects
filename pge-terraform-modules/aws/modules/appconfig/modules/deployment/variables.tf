variable "description" {
  description = "The description of the AppConfig application."
  type        = string
  default     = null
}

variable "application_id" {
  description = "The id of the application to deploy."
  type        = string
}

variable "configuration_profile_id" {
  description = "The id of the configuration profile to use."
  type        = string
}

variable "configuration_version" {
  description = "The configuration version to deplopy."
  type        = string
}

variable "strategy_id" {
  description = "The id of the deployment strategy to use."
  type        = string
  default     = "AppConfig.AllAtOnce"
}

variable "environment_id" {
  description = "The id of the environment to use."
  type        = string
}

variable "kms_key_id" {
  description = "The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias."
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
