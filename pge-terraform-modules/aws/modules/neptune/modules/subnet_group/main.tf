/*
*#AWS Neptune module
*Terraform module which creates subnet group
*/
#Filename     : aws/modules/neptune/modules/subnet_group/main.tf 
#database     : 11 July 2022
#Author       : TCS
#Description  : Terraform module for creation of subnet_group
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Module      : Neptune
#Description : This terraform module creates subnet_group

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

resource "aws_neptune_subnet_group" "neptune_subnet_group" {
  name        = var.neptune_subnet_group_name
  subnet_ids  = var.neptune_subnet_ids
  description = coalesce(var.neptune_subnet_group_description, format("%s subnet group - Managed by Terraform", var.neptune_subnet_group_name))
  tags        = local.module_tags
}