/*
*#AWS Neptune module
*Terraform module which creates cluster  endpoint
*/
#Filename     : aws/modules/neptune/modules/cluster_endpoint/main.tf 
#database     : 22 July 2022
#Author       : TCS
#Description  : Terraform module for creation of cluster_endpoint
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
#Description : This terraform module creates cluster_endpoint

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



resource "aws_neptune_cluster_endpoint" "neptune_cluster_endpoint" {
  cluster_identifier          = var.neptune_cluster_identifier
  cluster_endpoint_identifier = var.neptune_cluster_endpoint_identifier
  endpoint_type               = var.neptune_cluster_endpoint_type
  static_members              = var.members.static_members
  excluded_members            = var.members.excluded_members
  tags                        = local.module_tags
}