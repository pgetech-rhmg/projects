/*
*#AWS Neptune module
*Terraform module which creates cluster parameter group
*/
#Filename     : aws/modules/neptune/modules/cluster_parameter_group/main.tf 
#database     : 13 July 2022
#Author       : TCS
#Description  : Terraform module for creation of Cluster_parameter_group
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
#Description : This terraform module creates cluster_parameter_group

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.0.8"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}
resource "aws_neptune_cluster_parameter_group" "neptune_cluster_parameter_group" {
  family      = var.neptune_cluster_parameter_group_family
  name        = var.neptune_cluster_parameter_group_name
  description = coalesce(var.neptune_cluster_parameter_group_description, format("%s cluster parameter group - Managed by Terraform", var.neptune_cluster_parameter_group_name))

  #Hardcoded values as per SAF rule #3
  parameter {
    name         = "neptune_enable_audit_log"
    value        = "1"
    apply_method = "pending-reboot"
  }

  #Hardcoded values as per SAF rule #6 (As per AWS documentation, Depcrecated cluster parameter but still this parameter is part of cluster parameter group by default hence hardcoded values)
  parameter {
    name         = "neptune_enforce_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.key
      value = parameter.value

      /*apply_method cannot be immediate for static parameetr
      When you change a static parameter and save the cluster parameter group, 
      the parameter change takes effect after you manually reboot the DB instance. 
      Currently, all the Neptune DB parameters are static.*/
      apply_method = "pending-reboot"
    }
  }

  tags = local.module_tags
}