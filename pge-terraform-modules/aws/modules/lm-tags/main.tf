/*
 * # Locate & Mark Tags Terraform Module
 * Terraform module to manage required tags for Locate & MArk
*/
#
# Filename    : modules/lm-tags/main.tf
# Date        : 28 Feb 2025
# Author      : Sean Fairchild (s3ff@pge.com)
# Description : This terraform module applies mandatory tags to Locate & Mark the resources.
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

# This will pull the standard PGE tags from SSM
module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = data.aws_ssm_parameter.tag_appid.insecure_value
  CRIS               = data.aws_ssm_parameter.tag_cris.insecure_value
  Compliance         = split(",", data.aws_ssm_parameter.tag_compliance.insecure_value)
  DataClassification = data.aws_ssm_parameter.tag_dataclassification.insecure_value
  Environment        = data.aws_ssm_parameter.tag_environment.insecure_value
  Notify             = split(",", data.aws_ssm_parameter.tag_notify.insecure_value)
  Owner              = split(",", data.aws_ssm_parameter.tag_owner.insecure_value)
  Order              = data.aws_ssm_parameter.tag_order.insecure_value
}

data "aws_ssm_parameter" "tag_appid" {
  name = var.appid
}

data "aws_ssm_parameter" "tag_cris" {
  name = var.cris
}

data "aws_ssm_parameter" "tag_compliance" {
  name = var.compliance
}

data "aws_ssm_parameter" "tag_dataclassification" {
  name = var.dataclassification
}

data "aws_ssm_parameter" "tag_environment" {
  name = var.environment
}

data "aws_ssm_parameter" "tag_notify" {
  name = var.notify
}

data "aws_ssm_parameter" "tag_owner" {
  name = var.owner
}

data "aws_ssm_parameter" "tag_order" {
  name = var.order
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = module.tags.tags
}
