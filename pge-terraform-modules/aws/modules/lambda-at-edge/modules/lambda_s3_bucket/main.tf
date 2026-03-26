/*
 * # AWS Lambda@edge function module using Amazon S3
 * Terraform module which creates SAF2.0 Lambda@edge function in AWS
*/
#
#  Filename    : aws/modules/lambda-at-edge/modules/lambda_s3_bucket/main.tf
#  Date        : 20 September 2022
#  Author      : PGE
#  Description : Lambda terraform module creates a Lambda@edge Function
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
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

data "aws_region" "current" {}

data "external" "validate_region" {
  count   = (data.aws_region.current.name != "us-east-1") ? 1 : 0
  program = ["sh", "-c", ">&2 echo region has to be us-east-1; exit 1"]
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_at_edge.arn

  architectures           = [var.architectures]
  code_signing_config_arn = var.code_signing_config_arn
  description             = var.description
  handler                 = var.handler
  s3_bucket               = var.s3_bucket
  s3_key                  = var.s3_key
  s3_object_version       = var.s3_object_version
  memory_size             = var.memory_size
  package_type            = "Zip"
  publish                 = true
  runtime                 = var.runtime
  tags                    = local.module_tags
  timeout                 = var.timeout

  dynamic "file_system_config" {
    for_each = var.file_system_config_arn != null && var.file_system_config_local_mount_path != null ? [true] : []
    content {
      arn              = var.file_system_config_arn
      local_mount_path = var.file_system_config_local_mount_path

    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config_mode != null ? [true] : []
    content {
      mode = var.tracing_config_mode

    }
  }

  timeouts {
    create = var.lambda_function_create_timeouts
  }
}

/**
 * Policy to allow AWS Cloudfront to access this lambda function.
 */
data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}

/**
 * Make a role that AWS services can assume that gives them access to invoke our function.
 * This policy also has permissions to write logs to CloudWatch.
 */
resource "aws_iam_role" "lambda_at_edge" {
  name               = "${var.iam_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
  tags               = local.module_tags
}

resource "aws_iam_role_policy_attachment" "attach_managed_policy" {
  count      = length(var.policy_arns)
  policy_arn = element(var.policy_arns, count.index)
  role       = aws_iam_role.lambda_at_edge.name
}

#optional resources


resource "aws_lambda_function_event_invoke_config" "event_invoke_config" {
  count = var.event_invoke_config_create ? 1 : 0

  function_name                = aws_lambda_function.lambda_function.arn
  maximum_event_age_in_seconds = var.event_invoke_config_maximum_event_age_in_seconds
  maximum_retry_attempts       = var.event_invoke_config_maximum_retry_attempts
  qualifier                    = aws_lambda_function.lambda_function.version

  dynamic "destination_config" {
    for_each = var.destination_on_failure != null ? [true] : []
    content {
      dynamic "on_failure" {
        for_each = var.destination_on_failure != null ? [true] : []
        content {
          destination = var.destination_on_failure
        }
      }

      dynamic "on_success" {
        for_each = var.destination_on_success != null ? [true] : []
        content {
          destination = var.destination_on_success
        }
      }
    }
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  count = var.event_source_mapping_create ? 1 : 0

  batch_size                     = var.event_source_mapping_batch_size
  bisect_batch_on_function_error = var.event_source_mapping_bisect_batch_on_function_error
  enabled                        = var.event_source_mapping_enabled
  event_source_arn               = var.event_source_mapping_event_source_arn
  function_name                  = aws_lambda_function.lambda_function.arn
  function_response_types        = [var.event_source_mapping_function_response_types]

  maximum_batching_window_in_seconds = var.event_source_mapping_maximum_batching_window_in_seconds
  maximum_record_age_in_seconds      = var.event_source_mapping_maximum_record_age_in_seconds
  maximum_retry_attempts             = var.event_source_mapping_maximum_retry_attempts

  parallelization_factor      = var.event_source_mapping_parallelization_factor
  queues                      = var.event_source_mapping_queues
  starting_position           = var.event_source_mapping_starting_position
  starting_position_timestamp = var.event_source_mapping_starting_position_timestamp
  topics                      = var.event_source_mapping_topics
  tumbling_window_in_seconds  = var.event_source_mapping_tumbling_window_in_seconds

  dynamic "destination_config" {
    for_each = var.destination_arn_on_failure != null ? [true] : []
    content {
      on_failure {
        destination_arn = var.destination_arn_on_failure
      }
    }
  }

  dynamic "source_access_configuration" {
    for_each = var.source_access_configuration_type != null && var.source_access_configuration_uri != null ? [true] : []
    content {
      type = var.source_access_configuration_type
      uri  = var.source_access_configuration_uri
    }
  }

  dynamic "filter_criteria" {
    for_each = var.filter_criteria_pattern != null ? [true] : []

    content {
      filter {
        pattern = var.filter_criteria_pattern
      }
    }
  }

  dynamic "self_managed_event_source" {
    for_each = var.self_managed_event_source_endpoints != null ? [true] : []
    content {
      endpoints = var.self_managed_event_source_endpoints
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  count = var.lambda_permission_action != null ? 1 : 0

  action             = var.lambda_permission_action
  event_source_token = var.lambda_permission_event_source_token
  function_name      = aws_lambda_function.lambda_function.function_name
  principal          = var.lambda_permission_principal
  qualifier          = aws_lambda_function.lambda_function.version
  source_account     = var.lambda_permission_source_account
  source_arn         = var.lambda_permission_source_arn
}
