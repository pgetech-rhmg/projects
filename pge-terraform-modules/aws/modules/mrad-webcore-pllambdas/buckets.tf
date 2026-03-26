module "pipeline_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name   = local.pipeline_name
  force_destroy = true
  policy        = data.aws_iam_policy_document.pipeline_bucket.json
  tags          = var.tags
}

data "aws_iam_policy_document" "pipeline_bucket" {
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      module.pipeline_bucket.arn,
      "${module.pipeline_bucket.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
