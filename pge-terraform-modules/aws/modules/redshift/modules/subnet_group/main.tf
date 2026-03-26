/*
#AWS Redshift module
#Terraform module which creates subnet group
#Filename     : aws/modules/redshift/modules/subnet_group/main.tf 
#Date         : 13 July 2022
#Author       : TCS
#Description  : Terraform module for creation of subnet_group
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

#Description : Default for Tags
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



#Description : This terraform module creates Subnet Groups
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name        = var.subnet_group_name
  description = coalesce(var.subnet_group_description, format("%s subnet group - Managed by Terraform", var.subnet_group_name))
  subnet_ids  = var.subnet_ids
  tags        = local.module_tags
}