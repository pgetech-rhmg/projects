module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

### variables for aws_backup_vault ###

variable "vault_name" {
  description = "Name of the backup vault to create"
  type        = string
  validation {
    condition     = (length(var.vault_name) > 0)
    error_message = "Vault name can't be empty."
  }
}

variable "vault_kms_key_arn" {
  description = "The server-side encryption key that is used to protect your backups."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "A boolean that indicates that all recovery points stored in the vault are deleted so that the vault can be destroyed without error."
  type        = bool
  default     = false
}

### variables for aws_backup_vault_lock_configuration ###

variable "enable_vault_lock" {
  description = "Change to true to add a lock configuration for the backup vault"
  type        = bool
  default     = false
}

variable "changeable_for_days" {
  description = "The number of days before the lock date. If omitted creates a vault lock in governance mode, otherwise it will create a vault lock in compliance mode"
  type        = number
  default     = null
}

variable "max_retention_days" {
  description = "The maximum retention period that the vault retains its recovery points"
  type        = number
  default     = null
}

variable "min_retention_days" {
  description = "The minimum retention period that the vault retains its recovery points"
  type        = number
  default     = null
}

### variables for aws_backup_vault_policy ###

variable "create_vault_policy" {
  description = "Change to true to add IAM policy for the backup vault"
  type        = bool
  default     = false
}

variable "vault_iam_policy" {
  description = "The backup vault access policy document in JSON format"
  type        = string
  default     = null
}

### variables for vault_notifications ###

variable "create_vault_notifications" {
  description = "Change to true if vault notifications needs to be enabled"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events"
  type        = string
  default     = null
}

variable "backup_vault_events" {
  description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
  type        = list(string)
  default     = []
}
