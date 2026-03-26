/*
 * # AWS Lambda@edge function module using local file
*/
#
#  Filename    : aws/modules/lambda-at-edge/examples/lambda_function_local/main.tf
#  Date        : 20 September 2022
#  Author      : PGE
#  Description : Lambda terraform module creates a Lambda@edge Function


locals {
  optional_tags      = var.optional_tags
  policy_name        = var.policy_name
  policy_path        = var.policy_path
  policy_description = var.policy_description
  Order              = var.Order
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
  Order              = local.Order
}

resource "random_pet" "ledge" {
  length = 2
}

data "aws_iam_policy_document" "lambda_edge_exec_role_policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "${local.policy_name}-${random_pet.ledge.id}"
  path        = local.policy_path
  description = local.policy_description
  policy      = [data.aws_iam_policy_document.lambda_edge_exec_role_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}



#########################################
# Create Lambda Function
#########################################

module "lambda_edge_function" {
  source = "../../"


  providers = {
    aws = aws.east
  }

  function_name              = "${var.function_name}-${random_pet.ledge.id}"
  iam_name                   = "${var.iam_name}-${random_pet.ledge.id}"
  policy_arns                = concat(var.policy_arns_list, [module.iam_policy.arn])
  description                = var.description
  runtime                    = var.runtime
  local_zip_source_directory = "${path.module}/${var.local_zip_source_directory}"
  tags                       = merge(module.tags.tags, local.optional_tags)
  handler                    = var.handler
}

module "lambda_alias" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_alias"
  version = "0.1.1"

  providers = {
    aws = aws.east
  }

  lambda_alias_name             = var.lambda_alias_name
  lambda_alias_description      = var.lambda_alias_description
  lambda_alias_function_name    = module.lambda_edge_function.lambda_arn
  lambda_alias_function_version = "1"
}
