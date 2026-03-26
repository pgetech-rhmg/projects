/*
 * # AWS dms replication instance and subnet groups
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/

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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.instance_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


# To create a new replication subnet group
resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = var.replication_subnet_group_description
  replication_subnet_group_id          = var.replication_subnet_group_id

  subnet_ids = var.subnet_ids

  tags = local.module_tags
}


# To create a new replication instance
resource "aws_dms_replication_instance" "test" {
  allocated_storage            = var.instance_allocated_storage
  allow_major_version_upgrade  = var.instance_allow_major_version_upgrade
  apply_immediately            = var.instance_apply_immediately
  auto_minor_version_upgrade   = var.instance_version_upgrade
  availability_zone            = var.instance_availability_zone
  engine_version               = var.instance_engine_version
  multi_az                     = var.instance_multi_az
  kms_key_arn                  = var.instance_kms_key_arn
  preferred_maintenance_window = var.instance_preferred_maintenance
  publicly_accessible          = var.instance_publicly_accessible
  replication_instance_class   = var.instance_replication_instance_class
  replication_instance_id      = var.instance_replication_id
  replication_subnet_group_id  = aws_dms_replication_subnet_group.test.id

  tags = local.module_tags

  vpc_security_group_ids = var.vpc_security_group_ids

  timeouts {
    create = var.timeouts_create
    delete = var.timeouts_delete
    update = var.timeouts_update
  }

}