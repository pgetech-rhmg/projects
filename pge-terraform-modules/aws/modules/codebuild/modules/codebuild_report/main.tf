/*
 * # AWS Codebuild module creating Codebuild report
 * Terraform module which creates SAF2.0 Codebuild in AWS.
*/
#
# Filename    : aws/modules/codebuild/modules/codebuild_report/main.tf
# Date        : 20/04/2022
# Author      : TCS
# Description : AWS Codebuild report module main
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


resource "aws_codebuild_report_group" "codebuild_rg" {
  name           = var.codebuild_rg_name
  type           = var.codebuild_rg_type
  delete_reports = var.codebuild_rg_delete_reports
  tags           = local.module_tags


  export_config {
    type = var.codebuild_rg_export_type

    s3_destination {
      bucket              = var.codebuild_rg_bucket
      encryption_key      = var.codebuild_rg_kms
      encryption_disabled = false
      packaging           = var.codebuild_rg_packaging
      path                = var.codebuild_rg_path
    }
  }
}

resource "aws_codebuild_resource_policy" "codebuild_resource_policy" {
  resource_arn = aws_codebuild_report_group.codebuild_rg.arn
  policy       = var.codebuild_resource_policy
}