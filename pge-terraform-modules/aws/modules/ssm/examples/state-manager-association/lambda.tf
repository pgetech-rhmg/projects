# Filename    : ccoe-docker-images/terraform/codepipeline_dockerimages/lambda.tf
# Date        : 01-06-2023
# Author      : Tekyantra
# Description : Auto detect new docker images publhsied in Dockerhub
#


data "aws_partition" "current" {}

#KMS key module

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "lambda_kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = "${var.lambda_function_name}-kms-key-nm"
#   description = "${var.lambda_function_name} kms key"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = var.aws_role
#   kms_role    = module.lambda_iam_role.name
# }

module "lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.lambda_iam_name
  aws_service = ["lambda.amazonaws.com"]
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/lambda_policy.json", {
    account_num          = var.account_num
    partition            = data.aws_partition.current.partition
    aws_region           = var.aws_region
    lambda_function_name = var.lambda_function_name
  })]
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = var.lambda_function_name
  role          = module.lambda_iam_role.arn
  description   = "${var.lambda_function_name} for docker image tag auto detections"
  source_code = {
    source_dir = "${path.module}/templates"
  }
  runtime                       = "python3.9"
  vpc_config_security_group_ids = [module.security-group.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = "lambda_function.lambda_handler"
  tags                          = merge(module.tags.tags, local.optional_tags)
  timeout                       = 60
  # Provide a valid value for kms_key_arn.Invalid value gives validation error.
  environment_variables = {
    variables = {
      REGION  = var.aws_region
      KMS_KEY = null # replace with module.lambda_kms_key.key_id, after key creation 
    }

    kms_key_arn = null # replace with module.lambda_kms_key.key_arn, after key creation 
  }
}


#security group for snslambda 
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name              = "${var.lambda_function_name}-sg-lambda-test1"
  description       = "${var.lambda_function_name} security group for Lambda"
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = var.cidr_egress_rules_codebuild
  tags              = merge(module.tags.tags, local.optional_tags)
}

