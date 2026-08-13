variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Key Vault — must be 3-24 chars, alphanumeric and hyphens"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium"
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted vaults and secrets"
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90"
  }
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection to prevent permanent deletion during retention period"
  default     = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use Azure RBAC instead of vault access policies"
  default     = true
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Azure VMs to retrieve certificates stored as secrets"
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys"
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Azure Resource Manager to retrieve secrets"
  default     = false
}

variable "network_acls" {
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network ACL rules for the Key Vault"
  default     = null
  nullable    = true
}

variable "secrets" {
  type        = map(string)
  description = "Initial secrets to create — map of secret name to secret value"
  default     = {}
  # Plaintext secret values: mark sensitive so known values never render in
  # `terraform plan`/CLI/pipeline logs (IA-05 committed-secrets control intent).
  sensitive = true
}

variable "seed_secrets" {
  type        = list(string)
  description = <<-EOT
    Names of "hand-loaded" secrets to SEED with a placeholder so first-run
    dependents (e.g. a Container App referencing the secret by URI) can provision
    before an operator sets the real value. Terraform manages only their
    EXISTENCE — the value is created once as var.seed_secret_placeholder and then
    ignored (lifecycle ignore_changes), so a real value set in Key Vault after
    deploy is never overwritten on later applies. Use `secrets` (not this) for
    secrets Terraform should own the value of. Names must be plan-known literals.
  EOT
  default     = []
}

variable "seed_secret_placeholder" {
  type        = string
  description = "Placeholder value written to each seed_secrets entry on first creation. Non-secret by design (a marker the operator replaces). Never updated after creation."
  default     = "REPLACE-IN-KEY-VAULT"
}

variable "grant_deployer_secrets_officer" {
  type        = bool
  description = <<-EOT
    On an RBAC-authorized vault, whether to self-grant the deploying principal
    the "Key Vault Secrets Officer" role so this module can write var.secrets.
    Default true: creating an RBAC vault does NOT confer data-plane secret-write
    access, so without this the secret writes fail with 403 ForbiddenByRbac.
    Set false only when the deployer is granted secret-write access out of band
    (and you want to avoid the module managing a role assignment on the vault).
    Ignored when the vault uses access policies (enable_rbac_authorization=false)
    or when no secrets are managed.
  EOT
  default     = true
}

variable "secrets_officer_propagation_duration" {
  type        = string
  description = "How long to wait for the deployer's Secrets Officer role assignment to propagate before writing secrets (RBAC is eventually consistent). Only used when grant_deployer_secrets_officer applies."
  default     = "60s"
}
