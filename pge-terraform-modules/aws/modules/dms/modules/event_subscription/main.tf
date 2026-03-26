/*
 * # AWS dms replication instance and subnet groups
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline/modules/dms/main.tf
#  Date        : 20 april 2022
#  Author      : TCS
#  Description : creation of dms
# 

terraform {
  required_version = ">= 0.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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


resource "aws_dms_event_subscription" "eventone" {
  enabled          = var.event_enabled
  event_categories = var.event_categories
  name             = var.event_name
  sns_topic_arn    = var.sns_topic_arn
  source_ids       = var.source_ids
  source_type      = var.source_type

  tags = local.module_tags

  timeouts {
    create = var.timeouts_create
    delete = var.timeouts_delete
    update = var.timeouts_update
  }

}