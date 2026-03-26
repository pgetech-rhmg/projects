/*
 * # AWS Glue Dev Endpoint module.
 * Terraform module which creates SAF2.0 Glue Dev Endpoint in AWS.
*/

#
#  Filename    : aws/modules/glue/modules/dev-endpoint/main.tf
#  Date        : 22 August 2022
#  Author      : TCS
#  Description : Glue Dev Endpoint Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Module      : Creation of Glue Dev Endpoint
# Description : This terraform module creates a Glue Dev Endpoint.

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



resource "aws_glue_dev_endpoint" "glue_dev_endpoint" {

  name     = var.glue_dev_endpoint_name
  role_arn = var.glue_dev_endpoint_role_arn

  arguments                 = var.glue_dev_endpoint_arguments
  extra_jars_s3_path        = var.glue_dev_endpoint_extra_jars_s3_path
  extra_python_libs_s3_path = var.glue_dev_endpoint_extra_python_libs_s3_path
  glue_version              = var.glue_dev_endpoint_glue_version
  # If the worker_type is null, then number_of_nodes will work.
  number_of_nodes   = var.dev_endpoint.worker_type == null ? var.dev_endpoint.number_of_nodes : null
  number_of_workers = var.dev_endpoint.number_of_workers
  public_key        = var.glue_dev_endpoint_public_key
  # If the public_key is null, then public_keys will work.
  public_keys            = var.glue_dev_endpoint_public_key == null ? var.glue_dev_endpoint_public_keys : null
  security_configuration = var.glue_dev_endpoint_security_configuration
  security_group_ids     = var.glue_dev_endpoint_security_group_ids
  subnet_id              = var.glue_dev_endpoint_subnet_id
  worker_type            = var.dev_endpoint.worker_type
  tags                   = local.module_tags
}