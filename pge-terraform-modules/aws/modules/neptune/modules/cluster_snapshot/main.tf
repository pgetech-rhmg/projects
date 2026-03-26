/*
*#AWS Neptune module
*Terraform module which creates snapshot
*/
#Filename     : aws/modules/neptune/modules/cluster_snapshot/main.tf 
#database     : 11 July 2022
#Author       : TCS
#Description  : Terraform module for creation of snapshot
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
#Description : This terraform module creates snapshot

resource "aws_neptune_cluster_snapshot" "neptune_cluster_snapshot" {
  db_cluster_identifier          = var.db_cluster_identifier
  db_cluster_snapshot_identifier = var.db_cluster_snapshot_identifier

  timeouts {
    create = var.snapshot_create_timeouts
  }
}