# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming the key alias."
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

variable "purpose" {
  description = "Purpose suffix for the key alias (e.g., aurora, secrets, audit). Combined into alias/pge-epic-<app>-<env>-<purpose>."
  type        = string
}

variable "description" {
  description = "Human-readable description of the key."
  type        = string
}

# Optional inputs
variable "custom_alias" {
  description = "Full alias override (must start with alias/). Takes precedence over the auto-derived alias."
  type        = string
  default     = null
  nullable    = true
}

variable "key_usage" {
  description = "Intended use of the key (ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC)."
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be one of: ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC."
  }
}

variable "customer_master_key_spec" {
  description = "Type of key material (SYMMETRIC_DEFAULT for symmetric encryption; asymmetric specs for SIGN_VERIFY)."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "deletion_window_in_days" {
  description = "Waiting period in days before pending key deletion (7 to 30)."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic annual key rotation. SAF requires this for symmetric keys."
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create the key as multi-region. NFR Tool defaults to single-region."
  type        = bool
  default     = false
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled."
  type        = bool
  default     = true
}

variable "bypass_policy_lockout_safety_check" {
  description = "Bypass the safety check that prevents creating a key policy that locks out the principal updating it. Leave false unless absolutely necessary."
  type        = bool
  default     = false
}

variable "policy_json" {
  description = "Optional raw JSON key policy. When null, a SAF-aligned default policy is generated granting account root admin and adding a DenyFromInternet guard scoped to PG&E CIDR space."
  type        = string
  default     = null
  nullable    = true
}

variable "security_admin_role_name" {
  description = "Name of the IAM role granted lifecycle management actions (DeleteAlias, DisableKey, CancelKeyDeletion, EnableKey) on the default policy."
  type        = string
  default     = "SecurityAdmin"
}

variable "prisma_role_name" {
  description = "Name of the IAM role granted kms:* read/write for compliance scanning (Prisma Cloud) on the default policy."
  type        = string
  default     = "PrismaCloudReadWriteMasterMemberRole-member"
}

variable "internal_cidr_blocks" {
  description = "PG&E internal CIDR blocks used in the DenyFromInternet condition on the default policy."
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "131.89.0.0/16",
    "131.90.0.0/16",
  ]
}

variable "principal_org_id" {
  description = "PG&E AWS Organizations ID used in the DenyFromInternet ViaAWSService carve-out. When null, the org-id condition is omitted."
  type        = string
  default     = null
  nullable    = true
}
