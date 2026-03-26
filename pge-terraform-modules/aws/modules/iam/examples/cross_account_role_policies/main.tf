/*
 * # AWS IAM Role module
 * Terraform module which creates SAF2.0 IAM Role in AWS
*/
#
# Filename    : modules/iam/examples/cross_account_role_policies
# Date        : Nov 22, 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam role creation in multiple accounts with multiple policies
#

locals {
  name                   = var.name
  policy_arns_list       = var.policy_arns_list
  policy_name            = var.policy_name
  path                   = var.path
  description            = var.description
  AppID                  = var.AppID
  Environment            = var.Environment
  DataClassification     = var.DataClassification
  CRIS                   = var.CRIS
  Notify                 = var.Notify
  Owner                  = var.Owner
  Compliance             = var.Compliance
  Order                  = var.Order
  optional_tags          = var.optional_tags
  trusted_aws_principals = var.trusted_aws_principals
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowFullS3Access"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

#inline policy
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


#################################################
# Role Creation with Inline and Managed Policies
#################################################
module "iam_policy" {
  source      = "../../modules/iam_policy"
  name        = local.policy_name
  path        = local.path
  description = local.description
  policy      = [data.aws_iam_policy_document.inline_policy.json, data.aws_iam_policy_document.bucket_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "aws_cross_account_iam_role" {
  source                 = "../../"
  name                   = local.name
  trusted_aws_principals = local.trusted_aws_principals
  #Managed_Policies (AWS Managed Policies,Customer Managed Policies)
  policy_arns = concat(local.policy_arns_list, [module.iam_policy.arn])


  #inline_policy or read from file policy
  inline_policy = [data.aws_iam_policy_document.inline_policy.json, file("${path.module}/account_role_policy.json")]


  tags = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.iam_policy
  ]
}


