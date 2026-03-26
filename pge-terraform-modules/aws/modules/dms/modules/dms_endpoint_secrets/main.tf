/*
 * # AWS DMS Source Endpoint module.
 * Terraform module which creates SAF2.0 DMS Endpoint using secrets manager in AWS.
*/

#
#  Filename    : aws/modules/dms/modules/dms_endpoint/dms_endpoint_using_secrets/main.tf
#  Date        : 29 March 2022
#  Author      : TCS
#  Description : DMS Endpoint Creation
#

terraform {
  required_version = ">= 0.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : DMS Endpoint Creation
# Description : This terraform module creates a DMS source and target endpoint using secrets manager.

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

  secrets_manager_access_role_arn = var.source_endpoint_secrets_manager_access_role_arn
  secrets_manager_arn             = var.source_endpoint_secrets_manager_arn
  service_access_role             = var.source_endpoint_service_access_role
  ssl_mode                        = var.source_endpoint_ssl_mode
  certificate_arn                 = var.source_certificate_arn
  database_name                   = var.source_endpoint_database_name
  extra_connection_attributes     = var.source_endpoint_extra_connection_attributes
  tags                            = local.module_tags

}

resource "aws_dms_endpoint" "dms_target_endpoint" {

  endpoint_type = "target"
  endpoint_id   = var.target_endpoint_id
  engine_name   = var.target_endpoint_engine_name
  kms_key_arn   = var.target_endpoint_kms_key_arn

  secrets_manager_access_role_arn = var.target_endpoint_secrets_manager_access_role_arn
  secrets_manager_arn             = var.target_endpoint_secrets_manager_arn
  service_access_role             = var.target_endpoint_service_access_role
  ssl_mode                        = var.target_endpoint_ssl_mode
  certificate_arn                 = var.target_certificate_arn
  database_name                   = var.target_endpoint_database_name
  extra_connection_attributes     = var.target_endpoint_extra_connection_attributes
  tags                            = local.module_tags

}