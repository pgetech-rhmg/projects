###
# Supporting resources for Grafana Tempo
#
# IAM role and policy for Grafana Tempo to access S3 buckets
# S3 buckets for Tempo traces 
###
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "tempo_assume_role" {
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

module "tempo_traces_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  force_destroy = true
  bucket_name   = var.bucket_name_traces
  tags          = var.tags
}

data "aws_iam_policy_document" "tempo" {
  statement {
    sid    = "TempoStorage"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      module.tempo_traces_bucket.arn,
      "${module.tempo_traces_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "tempo_s3_policy" {
  name        = "${var.cluster_name}-tempo-s3-policy"
  description = "IAM policy for Tempo to access S3 buckets"
  policy      = data.aws_iam_policy_document.tempo.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "tempo_s3_attachment" {
  role       = aws_iam_role.tempo.name
  policy_arn = aws_iam_policy.tempo_s3_policy.arn
}

resource "aws_eks_pod_identity_association" "tempo" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.tempo.arn

  tags = var.tags
}

resource "aws_iam_role" "tempo" {
  name               = var.tempo_role_name
  description        = var.tempo_role_description
  assume_role_policy = data.aws_iam_policy_document.tempo_assume_role.json

  tags = var.tags
}