/*
 * # AWS Lambda function module using ECR image
 * Terraform module which creates SAF2.0 Lambda function in AWS
*/
##################################################################
#
#  Filename    : aws/modules/lm-lambda/main.tf
#  Date        : 17 Oct 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "tags" {
  source  = "app.terraform.io/pgetech/lm-tags/aws"
  version = "~> 0.1.5"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = local.lambda_role

  architectures                  = [var.architectures]
  code_signing_config_arn        = var.code_signing_config_arn
  description                    = var.description
  handler                        = var.handler
  image_uri                      = data.aws_ecr_image.placeholder_image.image_uri
  kms_key_arn                    = length(var.environment_variables) >= 0 ? var.kms_key_arn : null
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = "Image"
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  tags                           = module.tags.tags
  timeout                        = var.timeout

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != 512 ? [var.ephemeral_storage_size] : []
    content {
      size = ephemeral_storage.value
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config_target_arn != null ? [true] : []
    content {
      target_arn = var.dead_letter_config_target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables != null ? [true] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config_arn != null && var.file_system_config_local_mount_path != null ? [true] : []
    content {
      arn              = var.file_system_config_arn
      local_mount_path = var.file_system_config_local_mount_path

    }
  }

  dynamic "image_config" {
    for_each = var.image_config_command != null && var.image_config_entry_point != null && var.image_config_working_directory != null ? [true] : []
    content {
      command           = var.image_config_command
      entry_point       = var.image_config_entry_point
      working_directory = var.image_config_working_directory
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config_mode != null ? [true] : []
    content {
      mode = var.tracing_config_mode

    }
  }

  vpc_config {
    security_group_ids = flatten([var.vpc_config_security_group_ids, module.lambda_security_group.sg_id])
    subnet_ids         = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
  }

  timeouts {
    create = var.lambda_function_create_timeouts
  }

  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }
}

#optional resources

resource "aws_lambda_provisioned_concurrency_config" "provisioned_concurrency_config" {
  count = var.provisioned_concurrent_executions >= 1 ? 1 : 0

  function_name                     = aws_lambda_function.lambda_function.arn
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier                         = aws_lambda_function.lambda_function.version

  timeouts {
    create = var.provisioned_concurrency_config_create_timeouts
    update = var.provisioned_concurrency_config_update_timeouts
  }
}

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

  tags                           = module.tags.tags
  batch_size                     = var.event_source_mapping_batch_size
  bisect_batch_on_function_error = var.event_source_mapping_bisect_batch_on_function_error
  enabled                        = var.event_source_mapping_enabled
  event_source_arn               = var.event_source_mapping_event_source_arn
  function_name                  = aws_lambda_function.lambda_function.arn
  function_response_types        = compact([var.event_source_mapping_function_response_types])

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
  for_each = { for idx, perm in var.lambda_permissions : idx => perm }

  function_name      = aws_lambda_function.lambda_function.function_name
  statement_id       = each.value.statement_id
  action             = each.value.action
  event_source_token = each.value.event_source_token
  principal          = each.value.principal
  source_account     = each.value.source_account
  source_arn         = each.value.source_arn
}

resource "aws_lambda_permission" "lambda_alias_permission" {
  for_each = { for idx, perm in var.lambda_permissions : idx => perm }

  function_name      = aws_lambda_function.lambda_function.function_name
  statement_id       = each.value.statement_id
  action             = each.value.action
  event_source_token = each.value.event_source_token
  principal          = each.value.principal
  qualifier          = aws_lambda_alias.lambda_alias.name
  source_account     = each.value.source_account
  source_arn         = each.value.source_arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags              = module.tags.tags
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "latest"
  description      = "Alias for ${aws_lambda_function.lambda_function.function_name} lambda"
  function_name    = aws_lambda_function.lambda_function.arn
  function_version = "$LATEST"
}
