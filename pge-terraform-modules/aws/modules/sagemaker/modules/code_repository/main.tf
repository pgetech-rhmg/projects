/*
* # AWS Sagemaker module
* # Terraform module which creates code_repository
*/
# Filename     : aws/modules/sagemaker/modules/code_repository/main.tf 
# Date         : 25 Aug 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of code_repository

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



resource "aws_sagemaker_code_repository" "code_repository" {
  code_repository_name = var.code_repository_name
  git_config {
    repository_url = var.repository_url
    branch         = var.branch
    secret_arn     = var.secret_arn
  }
  tags = local.module_tags
}