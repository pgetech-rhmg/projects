/*
*#AWS Neptune module
*Terraform module which creates instance parameter group
*/
#Filename     : aws/modules/neptune/modules/instance_parameter_group/main.tf 
#database     : 13 July 2022
#Author       : TCS
#Description  : Terraform module for creation of instance_parameter_group


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
#Description : This terraform module creates instance_parameter_group

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

resource "aws_neptune_parameter_group" "instance_parameter_group" {
  family      = var.neptune_instance_parameter_group_family
  name        = var.neptune_instance_parameter_group_name
  description = coalesce(var.neptune_instance_parameter_group_description, format("%s instance parameter group - Managed by Terraform", var.neptune_instance_parameter_group_name))

  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.key
      value = parameter.value

      /*apply_method cannot be immediate for static parameetr
      When you change a static parameter and save the instance DB parameter group, 
      the parameter change takes effect after you manually reboot the DB instance. 
      Currently, all the Neptune DB parameters are static.*/
      apply_method = "pending-reboot"

    }
  }

  tags = local.module_tags
}