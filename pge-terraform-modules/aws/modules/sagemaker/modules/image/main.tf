/*
* # AWS Sagemaker module
* # Terraform module which creates image
Filename     : aws/modules/sagemaker/modules/image/main.tf 
Date         : 01 Sep 2022
Author       : TCS
Description  : Terraform sub-module for creation of image
*/

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



resource "aws_sagemaker_image" "image" {
  image_name   = var.image_name
  role_arn     = var.role_arn
  display_name = var.display_name
  description  = coalesce(var.description, format("%s sagemaker image", var.image_name))
  tags         = local.module_tags
}