/*
*#AWS Elastic Beanstalk module
*Terraform module which creates Elastic Beanstalk application
*/
#Filename     : aws/modules/elastic-beanstalk/main.tf
#database     : 13 Oct 2022
#Author       : TCS
#Description  : Terraform module for creation of Elastic Beanstalk application
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
#Description : This terraform module creates Elastic Beanstalk application

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_elastic_beanstalk_application" "elastic_beanstalk" {
  name        = var.name
  description = coalesce(var.description, format("%s elastic beanstalk application - Managed by Terraform", var.name))

  dynamic "appversion_lifecycle" {
    for_each = var.appversion_lifecycle.service_role != null ? [true] : []
    content {
      service_role          = var.appversion_lifecycle.service_role
      max_count             = var.appversion_lifecycle.max_count
      max_age_in_days       = var.appversion_lifecycle.max_age_in_days
      delete_source_from_s3 = var.appversion_lifecycle.delete_source_from_s3
    }
  }

  tags = local.module_tags
}