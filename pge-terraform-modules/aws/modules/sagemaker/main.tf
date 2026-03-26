/*
* # AWS Sagemaker module
* # Terraform module which creates aws_sagemaker_app
*/
# Filename     : aws/modules/sagemaker/modules/app/main.tf 
# Date         : 07 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_sagemaker_app

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



resource "aws_sagemaker_app" "app" {
  app_name          = var.name
  app_type          = var.app_type
  domain_id         = var.domain_id
  user_profile_name = var.user_profile_name
  resource_spec {
    instance_type               = var.instance_type
    lifecycle_config_arn        = var.lifecycle_config_arn
    sagemaker_image_arn         = var.sagemaker_image_arn
    sagemaker_image_version_arn = var.sagemaker_image_version_arn
  }
  tags = local.module_tags
}