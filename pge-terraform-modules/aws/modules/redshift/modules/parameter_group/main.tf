/*
 * # AWS Redshift
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/

terraform {
  required_version = ">= 1.1.0"
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



resource "aws_redshift_parameter_group" "parameter-group" {
  name = var.name
  #At this time, redshift-1.0 is the only version of the Amazon Redshift engine so it is the only default parameter group.  
  family      = "redshift-1.0"
  description = coalesce(var.description, format("%s parameter group - Managed by Terraform", var.name))

  # As per the SAF, the Redshift cluster parameter groups have "require_ssl" set to True and to track and log the database queries performed and connection attempts, logging data so "enable_user_activity_logging" set to true
  parameter {
    name  = "require_ssl"
    value = "true"
  }
  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
  #Dynamic block is used here to iterate over the available parameters for each name and value
  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.module_tags
}
