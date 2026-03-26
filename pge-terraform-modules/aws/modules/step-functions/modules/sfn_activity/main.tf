/*
 * # AWS Step Functions Activity
 * Terraform module which creates SAF2.0 step functions activity in AWS.
*/

#
#  Filename    : aws/modules/step_functions/modules/sfn_activity/main.tf
#  Date        : 11 Oct 2022
#  Author      : TCS
#  Description : Terraform module creates a step functions activity
#

terraform {
  required_version = ">= 1.1.0"
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



#Provides a Step Functions Activity resource
resource "aws_sfn_activity" "sfn_activity" {

  name = var.sfn_activity_name
  tags = local.module_tags
}