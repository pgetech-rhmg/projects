/*
 * # AWS Lambda function with S3 Bucket User module example
*/
#
#  Filename    : aws/modules/lambda/examples/lambda_function_with_s3_bucket/main.tf
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
  source = "../../modules/lambda_s3_bucket"

  function_name                 = "${var.function_name}_${random_string.name.result}"
  role                          = module.aws_lambda_iam_role.arn
  description                   = var.description
  runtime                       = var.runtime
  memory_size                   = var.memory_size
  s3_bucket                     = module.s3.id
  s3_key                        = aws_s3_object.lambda_object.key
  s3_object_version             = aws_s3_object.lambda_object.version_id
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
}

module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.1"
  bucket_name = "${var.s3_bucket_name}-${random_string.name.result}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, local.optional_tags)
}

resource "aws_s3_object" "lambda_object" {
  bucket = module.s3.id
  key    = var.bucket_object_key
  source = "${path.module}/${var.bucket_object_source}"
  etag   = filemd5("${path.module}/${var.bucket_object_source}")
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