/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM parameters in AWS
*/

# Filename    : modules/ssm/main.tf
# Date        : 15 September 2022
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : The module creates SSM parameters in AWS
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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}

data "external" "validate_securestring" {
  count   = (var.type == "SecureString" && var.key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for SecureString; exit 1"]
}


resource "aws_ssm_parameter" "default" {
  name            = var.name
  description     = var.description
  type            = var.type
  tier            = var.tier
  value           = var.value
  allowed_pattern = var.allowed_pattern
  data_type       = var.data_type
  key_id          = var.key_id
  tags            = local.module_tags
}

data "aws_ssm_parameter" "read" {
  name = aws_ssm_parameter.default.name
}


