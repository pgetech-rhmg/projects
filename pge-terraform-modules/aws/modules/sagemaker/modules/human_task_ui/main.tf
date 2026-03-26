/*
* # AWS Sagemaker module
* # Terraform module which creates human_task_ui
*/
# Filename     : aws/modules/sagemaker/modules/human_task_ui/main.tf 
# Date         : 25 Aug 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of human_task_ui

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



resource "aws_sagemaker_human_task_ui" "human_task_ui" {
  human_task_ui_name = var.human_task_ui_name
  ui_template {
    content = var.content
  }
  tags = local.module_tags
}