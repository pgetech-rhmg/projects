/*
 * # Azure Key Vault module
 * Terraform module which creates SAF2.0 Key Vault in Azure
*/
#
# Filename    : modules/key-vault/main.tf
# Date        : 25 Feb 2026
# Author      : PGE
# Description : This terraform module creates an Azure Key Vault with optional network ACLs and RBAC authorization.
#
# PURPOSE:
#   Provisions a PGE-compliant Azure Key Vault for secure storage and management of secrets, keys, and certificates.
#   Supports SAF2.0 compliance framework with comprehensive tagging and workspace integration.
#
# FEATURES:
#   - SAF2.0 compliant tagging with workspace-info integration
#   - Optional network access controls (ACLs) for secure connectivity
#   - RBAC authorization support for fine-grained access control
#   - Configurable soft delete and purge protection for data safety
#   - Support for disk encryption, deployment, and template deployment scenarios
#   - Dynamic network ACLs for flexible network policy configuration
#
# REQUIREMENTS:
#   - Azure subscription with appropriate permissions
#   - Pre-existing resource group
#   - Azure tenant ID for RBAC configuration
#   - (Optional) Virtual network subnets for network ACL rules
#
# EXAMPLE USAGE:
#   module "keyvault" {
#     source = "app.terraform.io/pgetech/azure/key-vault"
#     name   = "my-pge-kv"
#     location = "eastus"
#     resource_group_name = "my-rg"
#     tenant_id = data.azurerm_client_config.current.tenant_id
#   }
#

# Workspace information module for SAF2.0 compliance tagging
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Local variables for module configuration and tagging
locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Azure Key Vault resource
# Creates a secure vault for storing secrets, keys, and certificates
resource "azurerm_key_vault" "keyvault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  rbac_authorization_enabled      = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access_enabled
  sku_name                        = var.sku_name

  # Optional network access control list configuration
  # Restricts Key Vault access to specific networks and IP ranges
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  # Apply PGE-compliant tags including management and resource type metadata
  tags = merge(
    var.tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "key-vault"
    }
  )
}


