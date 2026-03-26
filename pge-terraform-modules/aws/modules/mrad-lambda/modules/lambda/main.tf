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
  }
}

locals {
  kms_role = var.kms_role
  aws_role = var.aws_role
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0"
  account_num = var.account_num
  aws_role    = var.aws_role
}

module "lambda_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"

  name          = "${var.lambda_name}-Role"
  description   = "IAM role for MRAD Lambda"
  aws_service   = var.service
  tags          = merge(module.mrad-common.tags, var.optional_tags)
  inline_policy = [data.aws_iam_policy_document.lambda_policy_document.json]
}

module "lambda-s3" {
  source                  = "app.terraform.io/pgetech/s3/aws"
  version                 = "0.1.1"
  bucket_name             = "${lower(var.lambda_name)}-${lower(var.TFC_CONFIGURATION_VERSION_GIT_BRANCH)}"
  tags                    = merge(module.mrad-common.tags, var.optional_tags)
  target_bucket           = data.aws_s3_bucket.logging_bucket.id
  target_prefix           = "${lower(var.lambda_name)}-${lower(var.TFC_CONFIGURATION_VERSION_GIT_BRANCH)}/"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  policy                  = data.aws_iam_policy_document.bucket_ssl_only_policy_document.json
  kms_key_arn             = module.kms_key.key_arn
}

resource "aws_s3_object" "object" {
  bucket = module.lambda-s3.id
  key    = uuid()
  source = data.archive_file.lambda_zip.output_path
  tags   = merge(module.mrad-common.tags, var.optional_tags)
}

module "lambda-mrad" {
  source                        = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version                       = "0.1.4"
  function_name                 = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  handler                       = var.handler
  runtime                       = var.runtime
  memory_size                   = var.memory
  role                          = module.lambda_iam_role.arn
  s3_bucket                     = module.lambda-s3.id
  s3_key                        = aws_s3_object.object.id
  timeout                       = var.timeout
  dead_letter_config_target_arn = var.dead_letter_queue_arn
  source_code_hash              = data.archive_file.lambda_zip.output_base64sha256
  environment_variables = merge(
    {
      variables = var.envvars
    },
    var.kms_key_arn != null ? { kms_key_arn = var.kms_key_arn } : {}
  )
  publish                       = true
  layers                        = var.layers
  tracing_config_mode           = var.tracing_enabled ? "Active" : "PassThrough"
  vpc_config_security_group_ids = compact(concat(data.aws_security_groups.lambda_sgs.ids, var.additional_security_groups))
  vpc_config_subnet_ids = [
    data.aws_subnet.private1.id,
    data.aws_subnet.private2.id,
    data.aws_subnet.private3.id
  ]
  tags   = merge(module.mrad-common.tags, var.optional_tags)
}

resource "aws_lambda_function_event_invoke_config" "lambda_config" {
  function_name          = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  maximum_retry_attempts = var.maximum_retry_attempts
  depends_on             = [module.lambda-mrad]
}

module "lambda-mrad-alias" {
  source                        = "app.terraform.io/pgetech/lambda/aws//modules/lambda_alias"
  version                       = "0.1.3"
  lambda_alias_name             = "${var.lambda_name}-latest-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  lambda_alias_description      = "lambda function alias for the latest version"
  lambda_alias_function_name    = module.lambda-mrad.lambda_arn
  lambda_alias_function_version = module.lambda-mrad.lambda_version
  depends_on                    = [module.lambda-mrad]
}



module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name        = "${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}-kms"
  description = "key used for mrad lambda"
  tags   = merge(module.mrad-common.tags, var.optional_tags)
  aws_role    = local.aws_role
  kms_role    = local.kms_role
  policy      = data.aws_iam_policy_document.kms_policy_document.json
}
