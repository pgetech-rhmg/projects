/*
 * # PG&E Mrad Lambda Module
 *  MRAD specific composite Terraform Lambda module to provision SAF compliant resources
*/
#
# Filename    : modules/mrad-lambda/main.tf
# Date        : 18 April 2023
# Author      : MRAD (mrad@pge.com)
# Description : This terraform module provisions MRAD compatible lambda functions
#

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.1.2"
    }
  }
}

locals {
  layers = concat(
    var.lambda_insights ? [local.lambda_insights_layer_arn_for_region[var.aws_region]] : [],
    var.layers,
  )
  managed_policy_arns = concat(
    var.lambda_insights ? ["arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"] : [],
    var.lambda_additional_iam_managed_policy_arns,
  )
  longest_possible_lambda_name = "${var.lambda_name}-latest-development"
 
  # Map account numbers to environment names for warmer logic
  account_to_env = {
    "990878119577" = "Dev"
    "471817339124" = "QA" 
    "712640766496" = "Prod"
  }
  
  # Determine if this is Dev environment (either by account number or env name)
  is_dev_environment = (
    var.account_num == "990878119577" || 
    var.aws_account == "Dev"
  )
  
  # Determine if we need to create a customer-managed KMS key
  create_kms_key = !var.use_aws_managed_s3_kms && var.kms_key_arn == null
  
  # KMS key for Lambda environment variables encryption
  # Use provided KMS key, or fallback to internally created one (if created), or null if using AWS-managed
  lambda_kms_key_arn = (
    var.kms_key_arn != null 
      ? var.kms_key_arn 
      : local.create_kms_key 
        ? module.kms_key[0].key_arn 
        : null
  )
  
  # KMS key for S3 bucket encryption
  # Use AWS-managed if flag is set, otherwise use same as Lambda KMS
  s3_kms_key_arn = var.use_aws_managed_s3_kms ? null : local.lambda_kms_key_arn
}

resource "null_resource" "lambda_name_length_validation" {
  lifecycle {
    precondition {
      condition = length(local.longest_possible_lambda_name) <= 140
      error_message = "A possible alias for this Lambda function is `${local.longest_possible_lambda_name}` with length ${length(local.longest_possible_lambda_name)}, exceeding the hard AWS limit of 140 characters. This will cause this function to fail to deploy in some or all AWS environments. Please create a new repository with a shorter name."
    }
  }
}

module "lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.lambda_name}-Lambda-Role-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  description = "IAM role for MRAD Lambda"
  aws_service = var.service
  tags        = merge(var.tags, var.optional_tags)
  policy_arns = [module.lambda_iam_policy.arn]
}

module "lambda_iam_policy" {
  source      = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version     = "0.0.8"
  name        = "${var.lambda_name}-Lambda-Policy-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  description = "A policy that allows a Lambda to execute via SQS"
  policy      = compact([data.aws_iam_policy_document.lambda_policy_document.json, var.lambda_additional_iam_policy])
  tags        = merge(var.tags, var.optional_tags)
}

resource "aws_iam_role_policy_attachment" "attach_managed_policy" {
  count      = length(local.managed_policy_arns)
  policy_arn = element(local.managed_policy_arns, count.index)
  role       = module.lambda_iam_role.name
}

module "lambda-s3" {
  source                  = "app.terraform.io/pgetech/s3/aws"
  version                 = "0.1.1"
  bucket_name             = "${lower(var.lambda_name)}-${lower(var.TFC_CONFIGURATION_VERSION_GIT_BRANCH)}-source"
  tags                    = merge(var.tags, var.optional_tags)
  target_bucket           = data.aws_s3_bucket.logging_bucket.id
  target_prefix           = "${lower(var.lambda_name)}-${lower(var.TFC_CONFIGURATION_VERSION_GIT_BRANCH)}/"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  policy                  = data.aws_iam_policy_document.bucket_ssl_only_policy_document.json
  kms_key_arn             = local.s3_kms_key_arn
  versioning              = var.bucket_versioning
}

resource "aws_s3_object" "object" {
  bucket = module.lambda-s3.id
  key    = "source.zip"
  source = data.archive_file.lambda_zip.output_path
  tags   = var.tags
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory
  role          = module.lambda_iam_role.arn
  timeout       = var.timeout
  publish       = var.publish
  
  # S3 deployment configuration
  s3_bucket         = module.lambda-s3.id
  s3_key            = aws_s3_object.object.id
  s3_object_version = null
  source_code_hash  = null
  
  # KMS encryption for environment variables
  kms_key_arn = local.lambda_kms_key_arn
  
  # Lambda layers
  layers = local.layers
  
  # Package configuration
  package_type = "Zip"
  
  # Environment variables
  dynamic "environment" {
    for_each = var.envvars != null ? [true] : []
    content {
      variables = var.envvars
    }
  }
  
  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_queue_arn != null ? [true] : []
    content {
      target_arn = var.dead_letter_queue_arn
    }
  }
  
  # VPC configuration
  vpc_config {
    security_group_ids = compact(concat(data.aws_security_groups.lambda_sgs.ids, var.additional_security_groups))
    subnet_ids = [
      data.aws_subnet.private1.id,
      data.aws_subnet.private2.id,
      data.aws_subnet.private3.id
    ]
  }
  
  # X-Ray tracing
  tracing_config {
    mode = var.tracing_enabled ? "Active" : "PassThrough"
  }
  
  tags = merge(var.tags, var.optional_tags)
}

resource "aws_lambda_provisioned_concurrency_config" "warmer" {
  count                             = (local.is_dev_environment || var.disable_warmer) ? 0 : 1
  function_name                     = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  provisioned_concurrent_executions = 1
  qualifier                         = module.lambda-mrad-alias.lambda_alias_all.name
  depends_on                        = [aws_lambda_function.lambda_function]
}

resource "aws_lambda_function_event_invoke_config" "lambda_config" {
  function_name          = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  maximum_retry_attempts = var.maximum_retry_attempts
  depends_on             = [aws_lambda_function.lambda_function]
}

module "lambda-mrad-alias" {
  source                        = "app.terraform.io/pgetech/lambda/aws//modules/lambda_alias"
  version                       = "0.1.3"
  lambda_alias_name             = coalesce(var.alias_name, "${var.lambda_name}-latest-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}")
  lambda_alias_description      = "lambda function alias for the latest version"
  lambda_alias_function_name    = aws_lambda_function.lambda_function.arn
  lambda_alias_function_version = aws_lambda_function.lambda_function.version
  depends_on                    = [aws_lambda_function.lambda_function]
}

module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"
  name    = "/aws/lambda/${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  tags    = merge(var.tags, var.optional_tags)
}

module "kms_key" {
  count   = local.create_kms_key ? 1 : 0
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name        = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}-kms"
  description = "KMS key for lambda-sumo ${var.lambda_name}"
  tags        = merge(var.tags, var.optional_tags)
  aws_role    = var.aws_role
  kms_role    = var.kms_role
  policy      = data.aws_iam_policy_document.kms_policy_document.json
}

module "sumo_logger" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "3.0.9-rc2"

  log_group_name = module.log_group.cloudwatch_log_group_name
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  account_num     = var.account_num
  aws_account     = var.aws_account
  aws_role        = var.aws_role
  tags            = merge(var.tags, var.optional_tags)
}
