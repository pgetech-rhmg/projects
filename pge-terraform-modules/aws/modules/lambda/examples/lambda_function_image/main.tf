/*
 * # AWS Lambda Function Image User module example
*/
#
#  Filename    : aws/modules/lambda/examples/lambda_function_image/main.tf
#  Date        : 02 Nov 2023
#  Author      : e6bo
#  Description : The terraform module creates a Lambda function using a container image

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

locals {
  name = "${var.name}_${random_string.name.result}"
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

module "lambda_function_image" {
  source = "../../modules/lambda_image"

  function_name                 = local.name
  tags                          = merge(module.tags.tags, var.optional_tags)
  role                          = module.aws_lambda_iam_role.arn
  description                   = var.description
  image_uri                     = var.image_uri
  enable_ephemeral_storage      = var.enable_ephemeral_storage
  ephemeral_storage_size        = var.ephemeral_storage_size
  vpc_config_security_group_ids = [module.security_group.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  environment_variables = {
    variables   = var.environment_variables
    kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  }
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

  # AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}

###################
# Data parameters #
###################

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