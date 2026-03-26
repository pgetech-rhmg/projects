/*
 * # AWS Cloudwatch synthetics module, this is used to create Clopudwatch Alarms
 * Terraform module which creates SAF2.0 Cloudwatch synthetics Alarms in AWS
*/

#
#  Filename    : aws/modules/cloudwatch-synthetics/main.tf
#  Date        : 14 Feb 2024
#  Author      : PGE
#  Description : AWS Cloudwatch synthetics module, this is used to create Clopudwatch Alarms
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

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


locals {

  rendered_file_content = templatefile("${path.module}/canary.js.tpl", {
    name            = var.name,
    take_screenshot = var.take_screenshot,
    api_hostname    = var.api_hostname,
    api_path        = var.api_path,
    region          = data.aws_region.current.name
  })
  zip = "lambda_canary-${sha256(local.rendered_file_content)}.zip"
  // to make sure the canary is redeployed whenever the rendered templated file is modified.

}
data "archive_file" "lambda_canary_zip" {
  type        = "zip"
  output_path = local.zip
  source {
    content  = local.rendered_file_content
    filename = "nodejs/node_modules/canary.js"

  }
}

resource "aws_synthetics_canary" "canary_api_calls" {
  name                 = var.name
  artifact_s3_location = "s3://${data.aws_s3_bucket.s3_canaries-reports.id}/"
  execution_role_arn   = var.execution_role_arn
  runtime_version      = var.runtime_version
  handler              = "canary.handler"
  zip_file             = local.zip
  start_canary         = true

  success_retention_period = 2
  failure_retention_period = 14

  schedule {
    expression          = "rate(${var.frequency} minutes)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 15
    active_tracing     = false
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  tags = local.module_tags

  depends_on = [
    data.archive_file.lambda_canary_zip,
  ]

}

