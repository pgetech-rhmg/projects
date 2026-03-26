/*
*#AWS Kinesis data stream module
*Terraform module which creates kinesis stream
*/
#Filename     : aws/modules/kinesis-datastream/main.tf 
#database     : 29 Aug 2022
#Author       : TCS
#Description  : Terraform module for creation of kinesis stream
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

#Module : kinesis data stream
#Description : This terraform module creates kinesis stream

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_kinesis_stream" "kinesis_stream" {
  name                      = var.name
  retention_period          = var.retention_period
  shard_level_metrics       = var.shard_level_metrics
  enforce_consumer_deletion = var.enforce_consumer_deletion

  encryption_type = var.encryption_type
  kms_key_id      = var.kms_key_id
  shard_count     = var.stream_mode.shard_count

  stream_mode_details {
    stream_mode = var.stream_mode.stream_mode_details
  }

  timeouts {
    create = try(var.timeouts.create, "5m")
    update = try(var.timeouts.update, "120m")
    delete = try(var.timeouts.delete, "120m")
  }

  tags = local.module_tags
}