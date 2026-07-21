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
  }))
  description = "Scoped RBAC role assignments granted to this identity. Keep to least privilege — e.g. [{ role_definition_name = \"AcrPull\", scope = <acr_id> }]."
  default     = []
}
