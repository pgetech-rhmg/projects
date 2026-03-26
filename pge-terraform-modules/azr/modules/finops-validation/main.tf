/*
 * # FinOps Validation module
 * Terraform module which validates partner configurations against FinOps CSV data
*/
#
# Filename    : modules/finops_validation/main.tf
# Date        : 11 Mar 2026
# Author      : PGE
# Description : This terraform module validates partner configurations for FinOps compliance.
#
# PURPOSE:
#   Validates partner configurations against approved AppID and Order number combinations
#   from a FinOps CSV file. Ensures cloud resource provisioning aligns with organizational
#   finance and billing requirements.
#
# FEATURES:
#   - Parses CSV data to extract AppID and Order number pairs
#   - Validates partner configurations against approved AppID/Order combinations
#   - Generates detailed validation status for each partner
#   - Identifies mismatches with specific failure reasons
#   - Filters approved partners for downstream vending operations
#   - Flexible partner configuration input supporting complex structures
#
# REQUIREMENTS:
#   - FinOps CSV file content as string (raw text)
#   - CSV must contain AppID in column 6 (index 5) and Order# in column 9 (index 8)
#   - Partner configs must include tags.AppID and tags.Order fields
#   - CSV header row is automatically skipped
#
# EXAMPLE USAGE:
#   module "finops_validation" {
#     source = "app.terraform.io/pgetech/azure/finops-validation"
#     finops_csv_content = file("${path.module}/finops_approved_list.csv")
#     partner_configs = {
#       partner1 = {
#         tags = {
#           AppID = "APP-1001"
#           Order = "811205"
#         }
#       }
#     }
#   }
#

terraform {
  required_version = ">= 1.1.0"
}

# ==============================================================================
# LOCAL VARIABLES AND VALIDATION LOGIC
# ==============================================================================
# The following locals parse the FinOps CSV and validate partner configurations
# against approved AppID and Order number combinations.
# ==============================================================================

locals {
  # Extract raw CSV content from input variable
  finops_csv_content = var.finops_csv_content

  # Split CSV into individual lines and filter out empty lines
  finops_lines = [
    for line in split("\n", local.finops_csv_content) :
    line if trimspace(line) != ""
  ]

  # Extract AppID (column 6) and Order# (column 9) pairs from CSV
  # Skips header row (idx > 0) and filters out blank entries
  finops_appid_order_pairs = [
    for idx, line in local.finops_lines : {
      app_id = trimspace(replace(split(",", line)[5], "\"", ""))
      order  = trimspace(replace(split(",", line)[8], "\"", ""))
    }
    if idx > 0 && length(split(",", line)) > 8 && trimspace(split(",", line)[5]) != "" && trimspace(split(",", line)[5]) != "(blank)" && trimspace(split(",", line)[8]) != "" && trimspace(split(",", line)[8]) != "(blank)"
  ]

  # approved_partner_configs keyed by subscription_name instead of partner_name
  # This aligns with subscription-based resource naming throughout the infrastructure
  approved_partner_configs = {
    for partner_name, config in var.partner_configs :
    config.subscription_name => config
    if contains([
      for pair in local.finops_appid_order_pairs :
      "${pair.app_id}|${pair.order}"
    ], "${try(config.tags.AppID, "UNKNOWN")}|${try(config.tags.Order, "UNKNOWN")}")
  }

  # Generate validation status for each partner configuration
  # Status includes AppID, Order#, and boolean approval flag
  finops_validation_status = {
    for partner_name, config in var.partner_configs :
    config.subscription_name => {
      app_id = try(config.tags.AppID, "NOT_SET")
      order  = try(config.tags.Order, "NOT_SET")
      approved = contains([
        for pair in local.finops_appid_order_pairs :
        "${pair.app_id}|${pair.order}"
      ], "${try(config.tags.AppID, "UNKNOWN")}|${try(config.tags.Order, "UNKNOWN")}")
    }
  }

  # Identify partners with mismatched AppID/Order combinations
  # Includes detailed reasoning for each mismatch (AppID mismatch, Order# mismatch, or both)
  finops_mismatches = [
    for partner_name, config in var.partner_configs :
    {
      subscription_name = config.subscription_name
      app_id            = try(config.tags.AppID, "NOT_SET")
      order             = try(config.tags.Order, "NOT_SET")
      approved = contains([
        for pair in local.finops_appid_order_pairs :
        "${pair.app_id}|${pair.order}"
      ], "${try(config.tags.AppID, "UNKNOWN")}|${try(config.tags.Order, "UNKNOWN")}")
      reason = (
        contains([
          for pair in local.finops_appid_order_pairs :
          "${pair.app_id}|${pair.order}"
        ], "${try(config.tags.AppID, "UNKNOWN")}|${try(config.tags.Order, "UNKNOWN")}")
        ) ? "APPROVED" : (
        contains([
          for pair in local.finops_appid_order_pairs : pair.app_id
          ], try(config.tags.AppID, "UNKNOWN")) ? "Order# does not match FinOps CSV for AppID" : (
          contains([
            for pair in local.finops_appid_order_pairs : pair.order
          ], try(config.tags.Order, "UNKNOWN")) ? "AppID does not match FinOps CSV for Order#" : "AppID and Order# do not match FinOps CSV"
      ))
    }
    if !contains([
      for pair in local.finops_appid_order_pairs :
      "${pair.app_id}|${pair.order}"
    ], "${try(config.tags.AppID, "UNKNOWN")}|${try(config.tags.Order, "UNKNOWN")}")
  ]
}
