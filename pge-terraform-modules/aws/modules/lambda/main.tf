/*
 * # AWS Lambda function module using local file
 * Terraform module which creates SAF2.0 Lambda function in AWS
*/
#
#  Filename    : aws/modules/lambda/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda Function
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    archive = {
      version = "~> 2.0"
    }
    random = {
      version = "~> 3.0"
    }
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
  kms_key_arn                    = var.environment_variables.kms_key_arn
  filename                       = data.archive_file.local_zip.output_path
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = "Zip"
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  source_code_hash               = var.allow_outofband_update ? null : data.archive_file.local_zip.output_base64sha256
  runtime                        = var.runtime
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

  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      log_format            = logging_config.value.log_format
      application_log_level = logging_config.value.application_log_level
      system_log_level      = logging_config.value.system_log_level
    }
  }

  timeouts {
    create = var.lambda_function_create_timeouts
  }
}

data "archive_file" "local_zip" {
  type        = "zip"
  source_dir  = var.source_code.source_dir
  output_path = "${resource.random_string.random.id}.zip"
  dynamic "source" {
    for_each = var.source_code.filename != null && var.source_code.content != null ? [true] : []
    content {
      content  = var.source_code.content
      filename = var.source_code.filename
    }
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
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
