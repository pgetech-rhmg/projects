#
#  Filename    : aws/modules/lm-lambda-pipeline/iam.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
module "codepipeline_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.lambda_name}-pipeline-role"
  aws_service   = ["codepipeline.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codepipeline_iam_role.json")]
}

module "lambda_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.lambda_name}-role"
  aws_service   = ["lambda.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codebuild_build_role.json")]
  policy_arns   = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
}

module "codebuild_build_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.lambda_name}-build-role"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codebuild_build_role.json")]
}
