/*
 * # AWS Lambda Function Inline User module example
*/
#
#  Filename    : aws/modules/lambda/examples/lambda_function_inline/main.tf
#  Date        : 31 Oct 2022
#  Author      : TCS
#  Description : The terraform module creates a Lambda function

locals {
  name = "${var.name}_${random_string.name.result}"
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.subnet_id3_name
}

data "aws_subnet" "lambda_function_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "lambda_function_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "lambda_function_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
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

  function_name = local.name
  role          = module.aws_lambda_iam_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    content  = var.content
    filename = var.filename
  }
  tags                          = merge(module.tags.tags, var.optional_tags)
  vpc_config_security_group_ids = [module.security_group.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  handler                       = var.handler
  reserved_concurrent_executions = var.reserved_concurrent_executions
  logging_config = var.logging_config
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.lambda_function_1.cidr_block, data.aws_subnet.lambda_function_2.cidr_block, data.aws_subnet.lambda_function_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.lambda_function_1.cidr_block, data.aws_subnet.lambda_function_2.cidr_block, data.aws_subnet.lambda_function_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, var.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}