/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM-Document in AWS
*/

# Filename    : modules/ssm-document/main.tf
# Date        : 01 May 2023
# Author      : PGE
# Description : The module will create a SSM document in JSON/YAML format
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

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

### SSM Document

resource "aws_ssm_document" "ssm_document" {
  name            = var.ssm_document_name
  document_type   = var.ssm_document_type
  document_format = var.ssm_document_format
  permissions     = var.ssm_document_permissions
  content         = var.ssm_document_content
  version_name    = var.ssm_document_version_name
  target_type     = var.ssm_document_target_type

  dynamic "attachments_source" {
    for_each = toset(var.ssm_document_attachments_source)
    content {
      key    = attachments_source.value.key
      values = attachments_source.value.values
      name   = attachments_source.value.name
    }
  }

  tags = local.module_tags

  # There is no AWS SSM API for reading attachments_source info directly
  lifecycle {
    ignore_changes = [attachments_source]
  }
}