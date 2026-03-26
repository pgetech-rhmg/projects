/*
*#AWS Neptune module
*Terraform module which creates cluster instance
*/
#Filename     : aws/modules/neptune/modules/cluster_instance/main.tf 
#database     : 20 July 2022
#Author       : TCS
#Description  : Terraform module for creation of cluster instance
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
#Description : This terraform module creates cluster instance

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


resource "aws_neptune_cluster_instance" "neptune_cluster_instance" {
  #Variable count is used to determine how many instances are needed.
  #We can create multiple instances with this module.
  #The default value is set to 1 in order to use this in the cluster with single instance.
  count      = var.instance_count > 0 ? var.instance_count : 0
  identifier = "${var.identifier}-${count.index}"

  apply_immediately = var.apply_immediately

  #As per saf rule #13 the instance should have the Auto Minor Version Upgrade feature enabled.
  auto_minor_version_upgrade = true
  availability_zone          = var.availability_zone
  cluster_identifier         = var.cluster_identifier
  engine                     = "neptune"

  engine_version               = var.engine_version
  instance_class               = var.instance_class
  neptune_subnet_group_name    = var.neptune_subnet_group_name
  neptune_parameter_group_name = var.neptune_parameter_group_name
  port                         = var.port
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  promotion_tier               = var.promotion_tier

  #As per saf rule #22 the instance should not be publicly accessible. That's why we hardcoded it.
  publicly_accessible = false
  tags                = local.module_tags

  dynamic "timeouts" {
    for_each = var.cluster_instance_timeouts
    content {
      create = lookup(timeouts.value, "create", "90m")
      update = lookup(timeouts.value, "update", "90m")
      delete = lookup(timeouts.value, "delete", "90m")
    }
  }
}