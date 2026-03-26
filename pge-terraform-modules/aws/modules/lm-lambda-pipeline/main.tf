/*
 * # AWS module that creates a codepipeline, ecr, and lambda function for Locate & Mark
 * Terraform module which creates SAF2.0 Lambda function in AWS
*/
#
#  Filename    : aws/modules/lm-lambda-pipeline/main.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
module "tags" {
  source  = "app.terraform.io/pgetech/lm-tags/aws"
  version = "~> 0.1.5"
}

data "aws_ecr_image" "placeholder_image" {
  repository_name = "lm-lambda-placeholder"
  image_tag       = "latest"
}

module "lambda_function_image" {
  source = "../lm-lambda"

  function_name                 = var.lambda_name
  tags                          = module.tags.tags
  role                          = module.lambda_role.arn
  description                   = "Lambda Execution role for lambda ${var.lambda_name}"
  image_uri                     = data.aws_ecr_image.placeholder_image.image_uri
  vpc_config_security_group_ids = [module.lambda_security_group.sg_id]
  vpc_config_subnet_ids         = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
}

module "ecr" {
  source               = "app.terraform.io/pgetech/ecr/aws"
  version              = "0.1.3"
  ecr_name             = "lambdas/${var.lambda_name}"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  tags                 = module.tags.tags
}
