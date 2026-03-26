
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_num}:root"]
    }
  }
  statement {
    sid    = "Allow access through S3 for all principals in the account that are authorized to use S3"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        var.account_num
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.${var.aws_region}.amazonaws.com"
      ]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_arn" "sts" {
  arn = data.aws_caller_identity.current.arn
}
