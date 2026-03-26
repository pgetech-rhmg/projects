/*
*#AWS Neptune module
*Terraform module which creates event subscription
*/
#Filename     : aws/modules/neptune/modules/event_subscription/main.tf 
#database     : 14 July 2022
#Author       : TCS
#Description  : Terraform module for creation of event subscription
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

#Module : Neptune
#Description : This terraform module creates event subscription

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

resource "aws_neptune_event_subscription" "neptune_event_subscription" {
  enabled          = var.enabled
  event_categories = var.event_categories
  name             = var.name
  sns_topic_arn    = var.sns_topic_arn
  source_ids       = var.neptune_source.source_ids
  source_type      = var.neptune_source.source_type
  tags             = local.module_tags

  dynamic "timeouts" {
    for_each = var.event_subscription_timeouts
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}