###
# Supporting resources for Grafana Loki
#
# IAM role and policy for Grafana Loki to access S3 buckets
# S3 buckets for Loki chunks and ruler storage
###
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "loki_assume_role" {
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

module "loki_chunks_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  force_destroy = true
  bucket_name   = var.bucket_name_chunks
  tags          = var.tags
}

module "loki_ruler_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  force_destroy = true
  bucket_name   = var.bucket_name_ruler
  tags          = var.tags
}

data "aws_iam_policy_document" "loki" {
  statement {
    sid    = "LokiStorage"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      module.loki_chunks_bucket.arn,
      "${module.loki_chunks_bucket.arn}/*",
      module.loki_ruler_bucket.arn,
      "${module.loki_ruler_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "loki_s3_policy" {
  name        = "${var.cluster_name}-loki-s3-policy"
  description = "IAM policy for Loki to access S3 buckets"
  policy      = data.aws_iam_policy_document.loki.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "loki_s3_attachment" {
  role       = aws_iam_role.loki.name
  policy_arn = aws_iam_policy.loki_s3_policy.arn
}

resource "aws_eks_pod_identity_association" "loki" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.loki.arn

  tags = var.tags
}

resource "aws_iam_role" "loki" {
  name               = var.loki_role_name
  description        = var.loki_role_description
  assume_role_policy = data.aws_iam_policy_document.loki_assume_role.json

  tags = var.tags
}