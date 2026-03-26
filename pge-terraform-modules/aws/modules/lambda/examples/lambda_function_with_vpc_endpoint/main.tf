/*
 * # AWS Lambda Function with Vpc-Endpoint User module example
*/
#
#  Filename    : aws/modules/lambda/examples/lambda_function_with_vpc_endpoint/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : The terraform module which creates a Lambda function and a vpc-endpoint.


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

module "security_group_vpc_endpoint" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = "${var.vpc_endpoint_sg_name}_${random_string.name.result}"
  description        = var.vpc_endpoint_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.vpc_endpoint_cidr_ingress_rules
  cidr_egress_rules  = var.vpc_endpoint_cidr_egress_rules
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

module "vpc_endpoint" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  service_name       = var.service_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  security_group_ids = [module.security_group_vpc_endpoint.sg_id]
  tags               = merge(module.tags.tags, local.optional_tags)
}