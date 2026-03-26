###
# Supporting resources for Grafana Mimir
#
# IAM role and policy for Grafana Mimir to access S3 buckets
# S3 buckets for Mimir blocks and ruler storage
###
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "mimir_assume_role" {
  dynamic "statement" {
    for_each = var.enable_pod_identity ? [1] : []

    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      principals {
        type        = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }
    }
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

module "mimir_blocks_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  force_destroy = true
  bucket_name   = var.bucket_name_blocks
  tags          = var.tags
}

module "mimir_ruler_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  force_destroy = true
  bucket_name   = var.bucket_name_ruler
  tags          = var.tags
}

data "aws_iam_policy_document" "mimir" {
  statement {
    sid    = "MimirStorage"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      module.mimir_blocks_bucket.arn,
      "${module.mimir_blocks_bucket.arn}/*",
      module.mimir_ruler_bucket.arn,
      "${module.mimir_ruler_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "mimir_s3_policy" {
  name        = "${var.cluster_name}-mimir-s3-policy"
  description = "IAM policy for Mimir to access S3 buckets"
  policy      = data.aws_iam_policy_document.mimir.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "mimir_s3_attachment" {
  role       = aws_iam_role.mimir.name
  policy_arn = aws_iam_policy.mimir_s3_policy.arn
}

resource "aws_eks_pod_identity_association" "mimir" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.mimir.arn

  tags = var.tags
}

resource "aws_iam_role" "mimir" {
  name               = var.mimir_role_name
  description        = var.mimir_role_description
  assume_role_policy = data.aws_iam_policy_document.mimir_assume_role.json

  tags = var.tags
}