#
# Filename    : modules/secretsmanager/main.tf
# Date        : 20 January 2021
# Author      : TCS
# Description : Secrets manager module main
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Secrets manager  
# Description : This terraform module creates a Secrets manager(SM) 
locals {
  namespace = "ccoe-tf-developers"
}

#Combines the user_defined_policy with the pge_compliance
data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    file("${path.module}/sm_pge_compliance_policy.json"),
    var.custom_policy
  ]
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_secretsmanager_secret" "sm" {
  name                    = var.secretsmanager_name
  name_prefix             = var.secretsmanager_name_prefix
  description             = var.secretsmanager_description
  kms_key_id              = var.kms_key_id
  policy                  = data.aws_iam_policy_document.combined.json
  recovery_window_in_days = var.recovery_window_in_days
  dynamic "replica" {
    for_each = var.replica_kms_key_id != null ? [true] : []
    content {
      kms_key_id = var.replica_kms_key_id
      region     = var.replica_region
    }
  }
  tags = local.module_tags
}

resource "aws_secretsmanager_secret_rotation" "sm_secret_rotation" {
  count               = var.rotation_enabled ? 1 : 0
  secret_id           = aws_secretsmanager_secret.sm.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_after_days
  }
}

resource "aws_secretsmanager_secret_version" "sm_secret_version" {
  count          = var.secret_version_enabled ? 1 : 0
  secret_id      = aws_secretsmanager_secret.sm.id
  secret_string  = var.secret_string
  secret_binary  = var.secret_binary
  version_stages = var.version_stages
}

