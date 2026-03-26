/*
 * # PG&E Entra Group Assignment Module
 *  Terraform base module to assign Azure RBAC roles to Entra groups at subscription scope
*/
#
# Filename    : modules/entra_group_assignment/main.tf
# Date        : 17 Feb 2026
# Author      : PGE
# Description : This terraform module assigns Azure RBAC roles to Entra groups for subscription level access

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.1"
    }
  }
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "azurerm_role_assignment" "read_only" {
  for_each             = toset(var.read_only_groups)
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "read_write" {
  for_each             = toset(var.read_write_groups)
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}
