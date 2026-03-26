/*
 * # AWS Lambda@edge function with S3 Bucket User module example
*/
#
#  Filename    : aws/modules/lambda-at-edge/examples/lambda_function_with_s3_bucket/main.tf
#  Date        : 20 September 2022
#  Author      : PGE
#  Description : LAMBDA terraform module creates a Lambda@edge Function


locals {
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
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

data "aws_caller_identity" "current" {}

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
  source = "../../modules/lambda_s3_bucket"

  providers = {
    aws = aws.east
  }

  function_name     = "${var.function_name}-${random_pet.ledge.id}"
  iam_name          = "${var.iam_name}-${random_pet.ledge.id}"
  policy_arns       = concat(var.policy_arns_list, [module.iam_policy.arn])
  description       = var.description
  runtime           = var.runtime
  s3_bucket         = module.s3.id
  s3_key            = aws_s3_object.lambda_object.key
  s3_object_version = aws_s3_object.lambda_object.version_id
  tags              = merge(module.tags.tags, local.optional_tags)
  handler           = var.handler
}

####################################################################################

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  providers = {
    aws = aws.east
  }

  bucket_name = "${var.s3_bucket_name}-${random_pet.ledge.id}"
  kms_key_arn = null # replace with module.kms_key.key_arn after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = module.tags.tags
}


data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }
}

resource "aws_s3_object" "lambda_object" {
  provider = aws.east
  bucket   = module.s3.id
  key      = var.bucket_object_key
  source   = "${path.module}/${var.bucket_object_source}"
  etag     = filemd5("${path.module}/${var.bucket_object_source}")
  tags     = merge(module.tags.tags, local.optional_tags)
}

######################################################################################

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = var.kms_name
#   kms_role    = local.kms_role
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
# }



