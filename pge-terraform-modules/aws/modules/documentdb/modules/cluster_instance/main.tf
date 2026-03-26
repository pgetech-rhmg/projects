/*
 * AWS DocumentDB Cluster Instance
 * Terraform module which creates SAF2.0 DocumentDB Cluster Instance in AWS
*/

#
#  Filename    : aws/modules/documentdb/modules/cluster_instance/main.tf
#  Date        : 09 August 2022
#  Author      : TCS
#  Description : Terraform module for creation of cluster instance
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

# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



# Provides an DocDB Cluster Resource Instance. 
# A Cluster Instance Resource defines attributes that are specific to a single instance in a DocDB Cluster.
resource "aws_docdb_cluster_instance" "cluster_instance" {
  # Variable count is used to determine how many instances are needed.
  # We can create multiple instances with this module.
  # The default value is set to 1 in order to use this in the cluster with single instance.
  count                        = var.instance_count
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  availability_zone            = var.availability_zone
  cluster_identifier           = var.cluster_identifier
  engine                       = var.engine
  identifier                   = var.identifier
  instance_class               = var.instance_class
  preferred_maintenance_window = var.preferred_maintenance_window
  promotion_tier               = var.promotion_tier
  tags                         = local.module_tags

  timeouts {
    create = try(var.timeouts.create, "90m")
    update = try(var.timeouts.update, "90m")
    delete = try(var.timeouts.delete, "90m")
  }
}
