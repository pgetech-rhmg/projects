/*
 * # AWS AppConfig module
 * Terraform module which creates SAF2.0 AppConfig configuration profile in AWS
*/
#
#  Filename    : aws/modules/appconfig/modules/configuration_profile/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates an AppConfig configuration profile
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}

resource "aws_appconfig_configuration_profile" "pge_profile" {
  name        = var.name
  description = var.description
  tags        = local.module_tags

  application_id     = var.application_id
  location_uri       = "hosted"
  kms_key_identifier = var.kms_key_id
}