##################################################################
#
#  Filename    : aws/modules/lm-lambda/local.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
locals {
  lambda_role = var.role == null ? module.lambda_iam_role[0].arn : var.role
}
