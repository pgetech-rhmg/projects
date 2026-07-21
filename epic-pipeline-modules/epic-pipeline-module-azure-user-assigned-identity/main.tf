resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  tags = var.tags
}

# Scoped RBAC role assignments for the identity. Callers pass only the roles
# the workload needs (e.g. AcrPull on a registry, Key Vault Secrets User on a
# vault) — least-privilege by construction (SECURITY-04 control intent).
resource "azurerm_role_assignment" "this" {
  for_each = { for r in var.role_assignments : "${r.role_definition_name}-${r.scope}" => r }

  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}
