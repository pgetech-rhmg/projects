# Filename    : modules/codepipeline/modules/codestar_notifications/lambda.tf
# Date        : 01-13-2023
# Author      : Tekyantra
# Description : SNS creation for Container codepipeline 
#

###########################################################
# Create Lambda  for code pipeline build failures 
###########################################################

# Calculate hash from actual source files to detect real code changes
# This prevents unnecessary updates from archive timestamp changes
locals {
  lambda_source_hash = filesha256("${path.module}/lambda_source_code/lambda_func.py")
}

resource "aws_iam_role" "role_for_lambda" {
  name = "Lambda-sns-role-${var.codepipeline_name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = local.module_tags
}

resource "aws_iam_policy" "policy_for_lambda" {
  name = "Lambda-sns-policy-${var.codepipeline_name}"
  policy = templatefile("${path.module}/codestar_iam_policies/lambda_policy.json",
    {
      account_num          = data.aws_caller_identity.current.account_id,
      partition            = data.aws_partition.current.partition,
      aws_region           = data.aws_region.current.name,
      lambda_function_name = "Lambda-sns-${var.codepipeline_name}",
      Topic_Arn_1          = resource.aws_sns_topic.sns-topic-trigger-lambda.arn,
      Topic_Arn_2          = resource.aws_sns_topic.sns-topic-trigger-email.arn
    }
  )
  tags = local.module_tags
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_lambda" {
  depends_on = [
    aws_iam_role.role_for_lambda,
    aws_iam_policy.policy_for_lambda
  ]
  role       = aws_iam_role.role_for_lambda.id
  policy_arn = aws_iam_policy.policy_for_lambda.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = resource.aws_sns_topic.sns-topic-trigger-lambda.arn
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = "Lambda-sns-${var.codepipeline_name}" #name can be changed
  role          = aws_iam_role.role_for_lambda.arn
  # Include the source hash in description to ensure Lambda updates when code actually changes
  # The filesha256 is based on actual file content, not archive timestamps
  description = "Lambda parse codebuild message and notify - ${local.lambda_source_hash}"
  source_code = {
    source_dir = "${path.module}/lambda_source_code"
  }
  runtime                       = var.run_time
  vpc_config_security_group_ids = [module.security-group-snslambda.sg_id]
  vpc_config_subnet_ids         = var.subnet_ids
  handler                       = "lambda_func.lambda_handler"
  tags                          = local.module_tags

  # Provide a valid value for kms_key_arn.Invalid value gives validation error.
  environment_variables = {
    variables = {
      Topic_Arn   = resource.aws_sns_topic.sns-topic-trigger-email.arn,
      aws_region  = data.aws_region.current.name
      environment = var.codestar_environment
    }
    kms_key_arn = var.codestar_lambda_encryption_key_id
  }
}

#security group for snslambda 
module "security-group-snslambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name              = "sg_snslambda_${var.codepipeline_name}"
  description       = var.sg_description_codestar
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules_SNS_codestar
  tags              = local.module_tags
}