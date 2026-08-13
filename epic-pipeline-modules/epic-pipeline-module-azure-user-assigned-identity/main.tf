resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  tags = var.tags
}

# Scoped RBAC role assignments for the identity. Callers pass only the roles
# the workload needs (e.g. AcrPull on a registry, Key Vault Secrets User on a
# vault) — least-privilege by construction (SECURITY-04 control intent).
#
# The for_each key is the role's stable identifier (`name` if supplied, else the
# role definition name) — NOT the scope. Scopes are typically resource IDs that
# are unknown until apply (e.g. an ACR/Key Vault created in the same run); a
# for_each map whose KEYS derive from apply-time values fails at plan
# ("Invalid for_each argument"). Keys must be known at plan time, so a caller
# assigning the same role to two different scopes disambiguates via `name`.
resource "azurerm_role_assignment" "this" {
  for_each = { for r in var.role_assignments : coalesce(r.name, r.role_definition_name) => r }

  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}
