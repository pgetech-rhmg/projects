variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "identity_name" {
  type        = string
  description = "Name of the user-assigned managed identity"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "role_assignments" {
  type = list(object({
    role_definition_name = string
    scope                = string
    name                 = optional(string)
  }))
  description = <<-EOT
    Scoped RBAC role assignments granted to this identity. Keep to least
    privilege — e.g. [{ role_definition_name = "AcrPull", scope = <acr_id> }].

    Each assignment is keyed by `name` if set, else `role_definition_name`.
    Because scopes are usually apply-time resource IDs, they CANNOT be part of
    the for_each key. If you assign the SAME role to two different scopes, give
    each a distinct `name` so the keys stay unique and plan-known — e.g.
    [{ name = "acr-pull", role_definition_name = "AcrPull", scope = <acr_id> },
     { name = "kv-secrets", role_definition_name = "Key Vault Secrets User", scope = <kv_id> }].
  EOT
  default     = []

  validation {
    condition = length(var.role_assignments) == length(distinct([
      for r in var.role_assignments : coalesce(r.name, r.role_definition_name)
    ]))
    error_message = "Duplicate role_assignments key: two assignments share the same role_definition_name. Give at least one a distinct `name` to disambiguate."
  }
}
