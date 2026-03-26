#
# Filename    : examples/keyvault/main.tf
# Description : Example usage of the Key Vault module
#

module "keyvault" {
  source                          = "../.."
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enable_rbac_authorization       = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access_enabled
  sku_name                        = var.sku_name
  network_acls                    = var.network_acls

  tags = merge(
    var.tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "key-vault"
    }
  )
}


