/*
* AWS DocumentDB module
* Terraform module which creates event subscription
*/
# Filename     : aws/modules/documentdb/modules/event_subscription/main.tf 
# Date     : 16 August 2022
# Author       : TCS
# Description  : The terraform module for creation of event_subscription
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

# Module : DocumentDB
# Description : This terraform module creates event_subscription

locals {
  namespace = "ccoe-tf-developers"
}

# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_docdb_event_subscription" "docdb_event_subscription" {
  name             = var.name
  sns_topic_arn    = var.sns_topic_arn
  source_ids       = var.docdb_source.source_ids
  source_type      = var.docdb_source.source_type
  event_categories = var.event_categories
  enabled          = var.enabled
  tags             = local.module_tags

  timeouts {
    create = try(var.event_subscription_timeouts.create, "40m")
    update = try(var.event_subscription_timeouts.update, "40m")
    delete = try(var.event_subscription_timeouts.delete, "40m")
  }
}