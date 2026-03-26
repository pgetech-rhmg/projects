/*
* # AWS SQS module
* Terraform module which creates SQS fifo queue
*/

#  Filename    : aws/modules/sqs/modules/sqs_fifo/main.tf
#  Date        : 02 February 2021
#  Author      : TCS
#  Description : Terraform module for creation of sqs fifo queue
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }
}
# Module      : sqs topic
# Description : This terraform module creates an encrypted sqs fifo queue

locals {
  namespace       = "ccoe-tf-developers"
  principal_orgid = "o-7vgpdbu22o"
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
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}


####################### aws sqs resource ######################
resource "aws_sqs_queue" "queue" {
  name = var.sqs_name

  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds


  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  fifo_queue                  = true
  fifo_throughput_limit       = var.fifo_throughput_limit
  deduplication_scope         = var.deduplication_scope
  content_based_deduplication = var.content_based_deduplication

  redrive_allow_policy = var.redrive_allow_policy
  redrive_policy       = var.redrive_policy

  tags = local.module_tags
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


#Combines the user_defined_policy with the pge_compliance
data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    templatefile("${path.module}/sqs_pge_compliance_policy.json",
      {
        sqs_name        = var.sqs_name
        account_num     = data.aws_caller_identity.current.account_id
        aws_region      = data.aws_region.current.name
        principal_orgid = local.principal_orgid
    }, ),
    var.policy
  ]
}

resource "aws_sqs_queue_policy" "policy" {
  queue_url = aws_sqs_queue.queue.url
  policy    = data.aws_iam_policy_document.combined.json
}
