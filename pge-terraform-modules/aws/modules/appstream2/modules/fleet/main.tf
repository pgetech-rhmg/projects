/*
* # AWS AppStream2.0 fleet module
* Terraform module which creates fleet for AppStream2.0 
*/
#Filename     : aws/modules/appstream2/modules/fleet/main.tf 
#Date         : 19 Aug 2022
#Author       : TCS
#Description  : Terraform module for creation of fleet

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Description : Default for Tags

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}


locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_appstream_fleet" "fleet" {
  instance_type                      = var.instance_type
  name                               = var.name
  description                        = coalesce(var.description, format("%s fleet", var.name))
  disconnect_timeout_in_seconds      = var.disconnect_timeout_in_seconds
  display_name                       = var.display_name
  enable_default_internet_access     = false
  fleet_type                         = var.fleet_type
  iam_role_arn                       = var.iam_role_arn
  idle_disconnect_timeout_in_seconds = var.idle_disconnect_timeout_in_seconds
  image_name                         = var.image_name
  image_arn                          = var.image_arn
  stream_view                        = var.stream_view
  max_user_duration_in_seconds       = var.max_user_duration_in_seconds
  compute_capacity {
    desired_instances = var.desired_instances
  }

  lifecycle {
    ignore_changes = [compute_capacity[0].desired_instances]
  }

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  # Domain join configuration - only created when domain_join_info is provided
  dynamic "domain_join_info" {
    for_each = var.domain_join_info != null ? [var.domain_join_info] : []
    content {
      directory_name                         = domain_join_info.value.directory_name
      organizational_unit_distinguished_name = domain_join_info.value.organizational_unit_distinguished_name
    }
  }
  tags = local.module_tags
}