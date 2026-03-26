/*
AWS Redshift module
Terraform module which creates Event Subscription
Filename     : aws/modules/redshift/modules/event_subscription/main.tf 
Date         : 13 July 2022
Author       : TCS
Description  : Terraform sub-module for creation of Event Subscription in redshift
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

#Default for tags
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


#Description : This terraform module creates Event Subscription
resource "aws_redshift_event_subscription" "redshift_event_subscription" {
  name             = var.event_subscription_name
  sns_topic_arn    = var.sns_topic_arn
  source_ids       = var.redshift_source.source_ids
  source_type      = var.redshift_source.source_type
  severity         = var.severity
  event_categories = var.event_categories
  enabled          = var.enabled
  tags             = local.module_tags
}