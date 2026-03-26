##################################################################
#
#  Filename    : aws/modules/lm-lambda/iam.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
module "lambda_iam_role" {
  count         = var.role == null ? 1 : 0
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.function_name}-role"
  aws_service   = ["lambda.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = var.role_inline_policies
  policy_arns = flatten([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", var.role_policies
  ])
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "LambdaECRImageRetrievalPolicy"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
