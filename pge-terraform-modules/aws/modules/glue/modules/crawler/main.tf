/*
 * # AWS Glue Crawler module.
 * Terraform module which creates SAF2.0 Glue Crawler in AWS.
*/

#
#  Filename    : aws/modules/glue/module/crawler/main.tf
#  Date        : 21 July 2022
#  Author      : TCS
#  Description : Glue Crawler Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Module      : Creation of Glue Crawler
# Description : This terraform module creates a Glue crawler.

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



resource "aws_glue_crawler" "glue_crawler" {

  name          = var.glue_crawler_name
  database_name = var.glue_crawler_database_name
  role          = var.glue_crawler_role

  classifiers   = var.glue_crawler_classifiers
  configuration = var.glue_crawler_configuration
  description   = coalesce(var.glue_crawler_description, format("%s crawler - Managed by Terraform", var.glue_crawler_name))

  dynamic "dynamodb_target" {
    for_each = var.dynamodb_target
    content {
      #For the value of path, give dynamodb table name.
      path = dynamodb_target.value.path

      scan_all  = lookup(dynamodb_target.value, "scan_all", true)
      scan_rate = lookup(dynamodb_target.value, "scan_rate", null)
    }
  }

  dynamic "jdbc_target" {
    for_each = var.jdbc_target
    content {
      #You can substitute the percent (%) character for a schema or table.
      #For databases that support schemas, enter MyDatabase/MySchema/% to match all tables in MySchema within MyDatabase.
      #Oracle Database and MySQL don’t support schema in the path; instead, enter MyDatabase/%. 
      #For Oracle Database, MyDatabase is the system identifier (SID).
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path

      exclusions = lookup(jdbc_target.value, "exclusions", null)
    }
  }

  dynamic "s3_target" {
    for_each = var.s3_target
    content {
      path = s3_target.value.path

      #Note that each crawler is limited to one Network connection so any future S3 targets will
      #also use the same connection (or none, if left blank).
      connection_name     = lookup(s3_target.value, "connection_name", null)
      exclusions          = lookup(s3_target.value, "exclusions", null)
      sample_size         = lookup(s3_target.value, "sample_size", null)
      event_queue_arn     = lookup(s3_target.value, "event_queue_arn", null)
      dlq_event_queue_arn = lookup(s3_target.value, "dlq_event_queue_arn", null)
    }
  }

  dynamic "catalog_target" {
    for_each = var.catalog_target
    content {
      # deletion_behavior of catalog target doesn't support DEPRECATE_IN_DATABASE.
      database_name = catalog_target.value.database_name
      tables        = catalog_target.value.tables
    }
  }

  dynamic "mongodb_target" {
    for_each = var.mongodb_target
    content {
      connection_name = mongodb_target.value.connection_name
      path            = mongodb_target.value.path

      scan_all = lookup(mongodb_target.value, "scan_all", null)
    }
  }

  dynamic "delta_target" {
    for_each = var.delta_target
    content {
      connection_name = delta_target.value.connection_name
      delta_tables    = delta_target.value.delta_tables
      write_manifest  = delta_target.value.write_manifest
    }
  }

  dynamic "schema_change_policy" {
    for_each = [var.glue_crawler_schema_change_policy]
    content {
      delete_behavior = lookup(schema_change_policy.value, "delete_behavior", "DEPRECATE_IN_DATABASE")
      update_behavior = lookup(schema_change_policy.value, "update_behavior", "UPDATE_IN_DATABASE")
    }
  }

  dynamic "lineage_configuration" {
    for_each = [var.glue_crawler_lineage_configuration]
    content {
      crawler_lineage_settings = lookup(lineage_configuration.value, "crawler_lineage_settings", "DISABLE")
    }
  }

  dynamic "recrawl_policy" {
    for_each = [var.glue_crawler_recrawl_policy]
    content {
      recrawl_behavior = lookup(recrawl_policy.value, "recrawl_behavior", "CRAWL_EVERYTHING")
    }
  }

  schedule               = var.glue_crawler_schedule
  security_configuration = var.glue_crawler_security_configuration
  table_prefix           = var.glue_crawler_table_prefix
  tags                   = local.module_tags
}