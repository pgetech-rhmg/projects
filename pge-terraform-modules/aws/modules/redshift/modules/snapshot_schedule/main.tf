/*
AWS Redshift module
#Terraform module which creates snapshot schedule & snapshot schedule association
#Filename     : aws/modules/redshift/modules/snapshot_schedule/main.tf 
#Date         : 19 July 2022
#Author       : TCS
#Description  : Terraform module for creation of subnet_group
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



resource "aws_redshift_snapshot_schedule" "snapshot_schedule" {
  identifier    = var.snapshot_schedule_identifier
  description   = var.snapshot_schedule_description
  definitions   = var.snapshot_schedule_definitions
  force_destroy = var.snapshot_schedule_force_destroy
  tags          = local.module_tags
}

#This loop will enable us to associate multiple clusters to a 'snapshot schedule'
#This will check the lenght of the variable and use count.index to look up the value
resource "aws_redshift_snapshot_schedule_association" "snapshot_schedule_association" {
  count               = length(var.snapshot_schedule_association)
  cluster_identifier  = var.snapshot_cluster_identifier
  schedule_identifier = aws_redshift_snapshot_schedule.snapshot_schedule.id
}