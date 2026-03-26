/*
 * # rds_automated_backups_replication module
 * Terraform module which creates SAF2.0 db_instance_automated_backups_replication resource.
 * This module can only be used in conjunction with Oracle and sqlserver modules
 * and is not intended to be used as a standalone module.
*/
#
#  Filename    : modules/rds/modules/rds_automated_backups_replication/main.tf
#  Date        : 07/29/2023
#  Author      : PGE
#  Description : AWS rds_automated_backups_replication main file.
#




terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_db_instance_automated_backups_replication" "this" {
  source_db_instance_arn = var.source_db_instance_arn
  kms_key_id             = var.kms_key_arn
  pre_signed_url         = var.pre_signed_url
  retention_period       = var.retention_period

}