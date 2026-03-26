/*
 * # Azure Policy Assignment module
 * Terraform module which creates SAF2.0 Policy Assignments in Azure
*/
#
# Filename    : modules/policy-assignment/main.tf
# Date        : 10 Mar 2026
# Author      : PGE
# Description : This terraform module creates Azure Policy Definitions and Subscription-scoped Policy Assignments for governance and compliance enforcement.
#
# PURPOSE:
#   Provisions PGE-compliant Azure Policy Assignments at the subscription scope to enforce tagging standards,
#   restrict allowed regions, and audit resource configurations in alignment with SAF2.0 and organizational policies.
#
# FEATURES:
#   - Custom policy definition to enforce AppID tag presence on resource groups
#   - Built-in policy assignments for required tag enforcement across configurable tag keys
#   - Allowed locations policy restricting deployments to approved US Azure regions
#   - Audit policy for virtual machines without managed disks
#   - Secure transfer enforcement policy for Azure Storage Accounts
#   - Parameterized partner_name and subscription_id for multi-subscription support
#

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Custom policy definition for AppID tag enforcement
resource "azurerm_policy_definition" "require_appid_tag" {
  name         = "require-appid-tag-${var.partner_name}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require AppID tag on resources for ${var.partner_name}"
  description  = "Enforces the presence of AppID tag with value ${var.app_id} on all resources"

  metadata = jsonencode({
    category = "Tags"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        }
      ]
    }
    then = {
      effect = "deny"
      details = {
        type = "Microsoft.Resources/tags"
        existenceCondition = {
          field  = "tags['AppID']"
          equals = var.app_id
        }
      }
    }
  })

  parameters = jsonencode({
    appIdValue = {
      type = "String"
      metadata = {
        displayName = "AppID Tag Value"
        description = "Value for the AppID tag"
      }
      defaultValue = var.app_id
    }
  })
}

# Assign custom AppID policy
resource "azurerm_subscription_policy_assignment" "require_appid" {
  name                 = "appid-tag-${var.partner_name}"
  policy_definition_id = azurerm_policy_definition.require_appid_tag.id
  subscription_id      = "/subscriptions/${var.subscription_id}"
  display_name         = "Require AppID tag for ${var.partner_name}"
  description          = "Enforces AppID tag on all resources in ${var.partner_name} subscription"
  # tflint: var.enforcement_mode wired here; "Default" = enforced, "DoNotEnforce" = audit-only
  enforce = var.enforcement_mode == "Default" ? true : false

  parameters = jsonencode({
    appIdValue = {
      value = var.app_id
    }
  })
}

# Assign built-in policy: Require a tag and its value on resources
resource "azurerm_subscription_policy_assignment" "require_tags" {
  for_each = toset(var.required_tags)

  name                 = "require-tag-${lower(each.key)}-${var.partner_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  display_name         = "Require ${each.key} tag for ${var.partner_name}"
  description          = "Enforces ${each.key} tag on all resources"
  # tflint: var.enforcement_mode wired here; "Default" = enforced, "DoNotEnforce" = audit-only
  enforce = var.enforcement_mode == "Default" ? true : false

  parameters = jsonencode({
    tagName = {
      value = each.key
    }
  })
}

# Assign built-in policy: Allowed locations
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-${var.partner_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  display_name         = "Allowed locations for ${var.partner_name}"
  description          = "Restricts resource deployment to approved Azure regions"
  # tflint: var.enforcement_mode wired here; "Default" = enforced, "DoNotEnforce" = audit-only
  enforce = var.enforcement_mode == "Default" ? true : false

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "East US",
        "East US 2",
        "West US",
        "West US 2",
        "Central US"
      ]
    }
  })
}

# Assign built-in policy: Audit VMs without managed disks
resource "azurerm_subscription_policy_assignment" "audit_vm_managed_disks" {
  name                 = "audit-vm-disks-${var.partner_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  display_name         = "Audit VMs without managed disks for ${var.partner_name}"
  description          = "Audits virtual machines that do not use managed disks"
  # tflint: var.enforcement_mode wired here; "Default" = enforced, "DoNotEnforce" = audit-only
  enforce = var.enforcement_mode == "Default" ? true : false
}

# Assign built-in policy: Require secure transfer for storage accounts
resource "azurerm_subscription_policy_assignment" "storage_secure_transfer" {
  name                 = "storage-https-${var.partner_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  display_name         = "Require secure transfer for storage accounts - ${var.partner_name}"
  description          = "Enforces HTTPS-only access to storage accounts"
  # tflint: var.enforcement_mode wired here; "Default" = enforced, "DoNotEnforce" = audit-only
  enforce = var.enforcement_mode == "Default" ? true : false
}