/*
* # AWS Sagemaker module
* # Terraform module which creates model_package_group
*/
# Filename     : aws/modules/sagemaker/modules/model_package_group/main.tf 
# Date         : 01 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of model_package_group

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
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



resource "aws_sagemaker_model_package_group" "model_package_group" {
  model_package_group_name        = var.model_package_group_name
  model_package_group_description = coalesce(var.model_package_group_description, format("%s model_package_group", var.model_package_group_name))
  tags                            = local.module_tags
}