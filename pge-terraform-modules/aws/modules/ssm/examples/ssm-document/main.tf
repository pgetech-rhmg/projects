/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Document in AWS
*/

# Filename    : aws/modules/ssm/examples/ssm-document/main.tf
# Date        : 01 May 2023
# Author      : PGE
# Description : The example code will create a SSM document in JSON format
#

locals {
  optional_tags = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#####################################################
# Creating SSM-Document in JSON Format 
#####################################################

module "ssm-document" {
  source = "../../modules/ssm-document"

  ssm_document_name    = var.ssm_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/ssm-document.json")

  tags = merge(module.tags.tags, local.optional_tags)
}