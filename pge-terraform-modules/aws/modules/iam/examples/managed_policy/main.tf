/*
 * # AWS IAM Policy module
 * Terraform module which creates SAF2.0 IAM Policy in AWS
*/
#
# Filename    : modules/iam/examples/managed_policy
# Date        : Dec 6, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam managed policy creation test 
#
locals {
  name               = var.name
  path               = var.path
  description        = var.description
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order 
  optional_tags      = var.optional_tags
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}
#########################################
# Get AWS Managed Policy
#########################################

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowFullS3Access"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect    = "Allow"
    actions   = ["cloudformation:Describe"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:CreateAssociation",
      "ssm:DescribeInstanceInformation",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ssm:GetParameter",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::rackspace-*/*"]
  }
}

###################################################################
# Create Policy from Data Source
###################################################################
module "iam_policy" {
  source      = "../../modules/iam_policy"
  name        = local.name
  path        = local.path
  description = local.description
  policy      = [data.aws_iam_policy_document.bucket_policy.json, data.aws_iam_policy_document.inline_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

