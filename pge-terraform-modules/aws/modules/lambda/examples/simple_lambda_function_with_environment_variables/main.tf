/*
 * # AWS Lambda function with Environment Variables User module example
*/
#
#  Filename    : aws/modules/lambda/examples/simple_lambda_function_with_environment_variables/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : The terraform module creates a Lambda function


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }


#########################################
# Create Lambda Function
#########################################

module "lambda_function" {
  source = "../../"

  function_name = "${var.function_name}_${random_string.name.result}"
  role          = module.aws_lambda_iam_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    source_dir = "${path.module}/${var.source_dir}"
  }
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
  environment_variables = {
    variables   = var.environment_variables
    kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  }
  layers = [module.lambda_layer.layer_version_arn]
}

module "lambda_layer" {
  source = "../../modules/lambda_layer_version_local"

  layer_version_layer_name               = "${var.layer_version_layer_name}_${random_string.name.result}"
  layer_version_compatible_architectures = var.layer_version_compatible_architectures
  layer_version_compatible_runtimes      = var.layer_version_compatible_runtimes
  local_zip_source_directory             = "${path.module}/${var.layer_version_local_zip_source_directory}"

  layer_version_permission_action       = var.layer_version_permission_action
  layer_version_permission_statement_id = var.layer_version_permission_statement_id
  layer_version_permission_principal    = var.layer_version_permission_principal
}

module "lambda_alias" {
  source = "../../modules/lambda_alias"

  lambda_alias_name             = var.lambda_alias_name
  lambda_alias_description      = var.lambda_alias_description
  lambda_alias_function_name    = module.lambda_function.lambda_arn
  lambda_alias_function_version = module.lambda_function.lambda_version
}

module "lambda_event_source_mapping_kinesis" {
  source            = "../../modules/event_source_mapping_kinesis"
  function_name     = module.lambda_function.lambda_arn
  event_source_arn  = aws_kinesis_stream.this.arn
  starting_position = var.starting_position
}

module "lambda_event_source_mapping_sqs" {
  source           = "../../modules/event_source_mapping_sqs"
  function_name    = module.lambda_function.lambda_arn
  event_source_arn = aws_sqs_queue.sqs_queue.arn
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "simple_sqs"
}

resource "aws_kinesis_stream" "this" {
  name        = "simple_kinesis"
  shard_count = 1
}



module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = "${var.lambda_sg_name}_${random_string.name.result}"
  description        = var.lambda_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules  = var.lambda_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.iam_name}_${random_string.name.result}"
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}