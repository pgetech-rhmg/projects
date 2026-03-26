/*
 * # AWS DMS Source Endpoint module.
 * Terraform module which creates SAF2.0 DMS Endpoint in AWS.
*/

#
#  Filename    : aws/modules/dms/modules/dms_endpoint/dms_endpoint_using_manual/main.tf
#  Date        : 29 March 2022
#  Author      : TCS
#  Description : DMS Endpoint Creation by providing access information manually using username and password.
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
      version = ">= 2.0"
    }
  }
}

# Module      : DMS Endpoint Creation
# Description : This terraform module creates a DMS source and target endpoint by providing access information manually using username and password.

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


data "external" "validate_kms_source_endpoint_kms_key_arn" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.source_endpoint_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "external" "validate_kms_target_endpoint_kms_key_arn" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.target_endpoint_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_dms_endpoint" "dms_source_endpoint" {

  endpoint_type = "source"
  endpoint_id   = var.source_endpoint_id
  engine_name   = var.source_endpoint_engine_name
  kms_key_arn   = var.source_endpoint_kms_key_arn

  username                    = var.source_endpoint_username
  password                    = var.source_endpoint_password
  port                        = var.source_endpoint_port
  ssl_mode                    = var.source_endpoint_ssl_mode
  server_name                 = var.source_endpoint_server_name
  certificate_arn             = var.source_certificate_arn
  database_name               = var.source_endpoint_database_name
  service_access_role         = var.source_endpoint_service_access_role
  extra_connection_attributes = var.source_endpoint_extra_connection_attributes
  tags                        = local.module_tags

}

resource "aws_dms_endpoint" "dms_target_endpoint" {

  endpoint_type = "target"
  endpoint_id   = var.target_endpoint_id
  engine_name   = var.target_endpoint_engine_name
  kms_key_arn   = var.target_endpoint_kms_key_arn

  username                    = var.target_endpoint_username
  password                    = var.target_endpoint_password
  port                        = var.target_endpoint_port
  ssl_mode                    = var.target_endpoint_ssl_mode
  server_name                 = var.target_endpoint_server_name
  certificate_arn             = var.target_certificate_arn
  database_name               = var.target_endpoint_database_name
  service_access_role         = var.target_endpoint_service_access_role
  extra_connection_attributes = var.target_endpoint_extra_connection_attributes
  tags                        = local.module_tags
}