/*
 * # AWS Lambda function module using ECR image
 * Terraform module which creates SAF2.0 Lambda function in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/lambda_image/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda Function
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
  is_dc_public_or_internal = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
  is_env_present           = var.environment_variables.variables != null ? true : false
  is_kms_required          = (!local.is_dc_public_or_internal && local.is_env_present) ? true : false
}

data "external" "is_valid_kms" {
  count   = (var.environment_variables.kms_key_arn != null && !can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.environment_variables.kms_key_arn))) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key arn entered is invalid; exit 1"]
}

data "external" "validate_kms" {
  count   = (local.is_kms_required && var.environment_variables.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key arn is mandatory for the DataClassfication type; exit 1"]
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = var.role

  architectures                  = [var.architectures]
  code_signing_config_arn        = var.code_signing_config_arn
  description                    = var.description
  handler                        = var.handler
  image_uri                      = var.image_uri
  kms_key_arn                    = var.environment_variables.kms_key_arn
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = "Image"
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  tags                           = local.module_tags
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
    for_each = var.environment_variables.variables != null ? [true] : []
    content {
      variables = var.environment_variables.variables
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

  dynamic "vpc_config" {
    for_each = var.vpc_config_security_group_ids != null && var.vpc_config_subnet_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_config_security_group_ids
      subnet_ids         = var.vpc_config_subnet_ids
    }
  }
  timeouts {
    create = var.lambda_function_create_timeouts
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
