/*
* AWS DocumentDB module
* Terraform module which creates global_cluster
*/
# Filename     : aws/modules/documentdb/modules/global_cluster/main.tf
# Date         : 17 Aug 2022
# Author       : TCS
# Description  : Terraform module for creation of global cluster

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module : DocumentDB
# Description : This terraform module creates global cluster

resource "aws_docdb_global_cluster" "global_cluster" {
  count = var.source_db_cluster_identifier == null ? 1 : 0

  global_cluster_identifier = var.global_cluster_identifier
  database_name             = var.database_name
  deletion_protection       = var.deletion_protection
  engine                    = var.engine
  engine_version            = var.engine_version

  # As per SAF rule storage_encrypted is hardcoded to true.
  storage_encrypted = true

  timeouts {
    create = try(var.timeouts.create, "5m")
    update = try(var.timeouts.update, "5m")
    delete = try(var.timeouts.delete, "5m")
  }

}

# Module : DocumentDB
# Description : This terraform module creates global cluster for existing cluster

resource "aws_docdb_global_cluster" "global_cluster_for_existing_cluster" {
  count = var.source_db_cluster_identifier != null ? 1 : 0

  global_cluster_identifier    = var.global_cluster_identifier
  database_name                = var.database_name
  deletion_protection          = var.deletion_protection
  source_db_cluster_identifier = var.source_db_cluster_identifier

  timeouts {
    create = try(var.timeouts.create, "5m")
    update = try(var.timeouts.update, "5m")
    delete = try(var.timeouts.delete, "5m")
  }

}