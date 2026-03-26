/*
*#AWS Elastic Beanstalk module
*Terraform module which creates Elastic Beanstalk application version
*/
#Filename     : aws/modules/elastic-beanstalk/modules/elastic_beanstalk_application_version/main.tf
#database     : 14 Oct 2022
#Author       : TCS
#Description  : Terraform module for creation of Elastic Beanstalk application version
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

#Module :  Elastic Beanstalk
#Description : This terraform module creates Elastic Beanstalk application version

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_elastic_beanstalk_application_version" "application_version" {
  application = var.application
  bucket      = var.bucket
  key         = var.key
  name        = var.name

  description  = coalesce(var.description, format("%s - Managed by Terraform", var.name))
  force_delete = var.force_delete
  tags         = local.module_tags

}