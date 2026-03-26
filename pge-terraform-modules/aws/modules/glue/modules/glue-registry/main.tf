/*
*#AWS Glue registry module.
*Terraform module which creates SAF2.0 Glue registry in AWS.
*/
#Filename     : aws/modules/glue/modules/glue-registry/main.tf 
#Date         : 19 August 2022
#Author       : TCS
#Description  : Glue registry Creation
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

#Module : Creation of Glue registry
#Description : This terraform module creates a Glue registry.

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



resource "aws_glue_registry" "glue_registry" {
  registry_name = var.glue_registry_name
  description   = coalesce(var.glue_registry_description, format("%s - Managed by Terraform", var.glue_registry_name))
  tags          = local.module_tags
}