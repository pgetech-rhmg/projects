/*
* # AWS Sagemaker module
* # Terraform module which creates studio_lifecycle_config
*/
# Filename     : aws/modules/sagemaker/modules/studio_lifecycle_config/main.tf 
# Date         : 02 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of studio_lifecycle_config

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



resource "aws_sagemaker_studio_lifecycle_config" "studio_lifecycle_config" {
  studio_lifecycle_config_name     = var.studio_lifecycle_config_name
  studio_lifecycle_config_app_type = var.studio_lifecycle_config_app_type
  studio_lifecycle_config_content  = var.studio_lifecycle_config_content
  tags                             = local.module_tags
}