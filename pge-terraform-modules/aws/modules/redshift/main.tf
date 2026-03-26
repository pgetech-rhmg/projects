/*
AWS Redshift module
Terraform module which creates Redshift Cluster
Filename     : aws/modules/redshift/modules/main.tf 
Date         : 01 Aug 2022
Author       : TCS
Description  : Terraform sub-module for creation of Cluster in redshift
*/
terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  bucket_name = "pge-central-redshiftlogs"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}


resource "aws_redshift_cluster" "Cluster" {

  cluster_identifier                   = var.cluster_identifier
  database_name                        = var.database_name
  node_type                            = var.node_type
  cluster_type                         = var.cluster_type
  master_password                      = var.master_password
  master_username                      = var.master_username
  vpc_security_group_ids               = var.vpc_security_group_ids
  cluster_subnet_group_name            = var.cluster_subnet_group_name
  availability_zone                    = var.redshift_availability_zone.availability_zone
  availability_zone_relocation_enabled = var.redshift_availability_zone.availability_zone_relocation_enabled
  preferred_maintenance_window         = var.preferred_maintenance_window
  cluster_parameter_group_name         = var.cluster_parameter_group_name
  automated_snapshot_retention_period  = var.automated_snapshot_retention_period
  port                                 = var.port
  cluster_version                      = var.cluster_version
  #As per SAF rule No:13
  allow_version_upgrade = true
  apply_immediately     = false
  number_of_nodes       = var.number_of_nodes
  #As per SAF rule No:08
  publicly_accessible = false
  #As per SAF rule No:01
  encrypted = true
  #As per SAF rule No:22
  enhanced_vpc_routing             = true
  kms_key_id                       = var.kms_key_id
  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier        = var.final_snapshot_identifier
  snapshot_identifier              = var.snapshot_identifier
  snapshot_cluster_identifier      = var.snapshot_cluster_identifier
  owner_account                    = var.owner_account
  iam_roles                        = var.iam_roles
  maintenance_track_name           = var.maintenance_track_name
  manual_snapshot_retention_period = var.manual_snapshot_retention_period

  timeouts {
    create = try(var.timeouts.create, "75m")
    update = try(var.timeouts.update, "75m")
    delete = try(var.timeouts.delete, "40m")
  }
  tags = local.module_tags
}


resource "aws_redshift_snapshot_copy" "snapshot_copy" {
  for_each = var.snapshot_copy

  cluster_identifier       = aws_redshift_cluster.Cluster.id
  destination_region       = each.value.destination_region
  retention_period         = try(each.value.retention_period, null)
  snapshot_copy_grant_name = try(each.value.snapshot_copy_grant_name, null)
}

#As per SAF rule No:06 
resource "aws_redshift_logging" "Cluster_logging" {
  cluster_identifier   = aws_redshift_cluster.Cluster.id
  log_destination_type = "s3"
  bucket_name          = local.bucket_name
  s3_key_prefix        = var.s3_key_prefix
}