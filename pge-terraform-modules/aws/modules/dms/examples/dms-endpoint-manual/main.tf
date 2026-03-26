/*
* # AWS DMS with usage example
* Terraform module which creates SAF2.0 dms resources in AWS.
* SSM Parameter store for storing username and password is a pre-requisite and must be existing to run this example. 
*/
#
# Filename    : modules/dms/examples/dms-endpoint-manual/main.tf
# Date        : 27 July 2022
# Author      : TCS
# Description : The Terraform usage example creates aws dms endpoint by providing access information manually using username and password.


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name        = var.kms_name
#   description = var.kms_description
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
#   tags        = merge(module.tags.tags, local.optional_tags)
# }

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "dms_username" {
  name = var.ssm_parameter_dms_username
}

data "aws_ssm_parameter" "dms_password" {
  name = var.ssm_parameter_dms_password
}

module "dms_endpoint" {
  source = "../../modules/dms_endpoint_manual"

  source_endpoint_id            = var.source_endpoint_id
  source_endpoint_engine_name   = var.source_endpoint_engine_name
  source_endpoint_kms_key_arn   = null # replace with module.kms_key.key_arn, after key creation
  source_endpoint_server_name   = var.source_endpoint_server_name
  source_endpoint_database_name = var.source_endpoint_database_name
  source_endpoint_ssl_mode      = var.source_endpoint_ssl_mode
  source_endpoint_username      = data.aws_ssm_parameter.dms_username.value
  source_endpoint_password      = data.aws_ssm_parameter.dms_password.value
  source_endpoint_port          = var.source_endpoint_port
  source_certificate_arn        = var.source_certificate_arn

  target_endpoint_id            = var.target_endpoint_id
  target_endpoint_engine_name   = var.target_endpoint_engine_name
  target_endpoint_kms_key_arn   = null # replace with module.kms_key.key_arn, after key creation
  target_endpoint_server_name   = var.target_endpoint_server_name
  target_endpoint_database_name = var.target_endpoint_database_name
  target_endpoint_ssl_mode      = var.target_endpoint_ssl_mode
  target_certificate_arn        = var.target_certificate_arn
  target_endpoint_username      = var.target_endpoint_username
  target_endpoint_password      = var.target_endpoint_password
  target_endpoint_port          = var.target_endpoint_port
  tags                          = merge(module.tags.tags, local.optional_tags)
}

