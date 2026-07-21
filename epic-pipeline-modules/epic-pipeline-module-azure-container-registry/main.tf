resource "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  sku           = var.sku
  admin_enabled = var.admin_enabled

  # Public network access is only togglable on Premium; on Basic/Standard the
  # registry is public and this attribute is ignored by Azure.
  public_network_access_enabled = var.public_network_access_enabled

  # Untagged-manifest retention (Premium SKU only). null leaves it unset.
  retention_policy_in_days = var.sku == "Premium" ? var.retention_policy_days : null

  tags = var.tags
}
