/*
* AWS DocumentDB module
* Terraform module which creates cluster snapshot
*/
# Filename     : aws/modules/documentdb/modules/cluster_snapshot/main.tf
# Date         : 11 Aug 2022
# Author       : TCS
# Description  : Terraform module for creation of cluster snapshot
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

#Module : DocumentDB
#Description : This terraform module creates snapshot

resource "aws_docdb_cluster_snapshot" "docdb_cluster_snapshot" {
  db_cluster_identifier          = var.db_cluster_identifier
  db_cluster_snapshot_identifier = var.db_cluster_snapshot_identifier

  timeouts {
    create = try(var.timeouts.create, "20m")
  }
}