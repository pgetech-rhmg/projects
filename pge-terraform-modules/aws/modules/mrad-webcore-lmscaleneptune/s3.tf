module "lambda_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name   = local.s3_bucket
  force_destroy = true
  policy        = data.aws_iam_policy_document.lambda_bucket.json
  tags          = var.tags
}

data "aws_iam_policy_document" "lambda_bucket" {
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      module.lambda_bucket.arn,
      "${module.lambda_bucket.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_object" "lambda_zip" {
  bucket = module.lambda_bucket.id
  key    = "artifacts/lambda.zip"
  source = data.archive_file.lambda_zip.output_path
  tags = {
    AppID              = try(var.tags["AppID"], "2586")
    Environment        = try(var.tags["Environment"], null)
    DataClassification = try(var.tags["DataClassification"], "Internal")
    CRIS               = try(var.tags["CRIS"], "Low")
    Notify             = try(var.tags["Notify"], "engage-devops@pge.com")
    Owner              = try(var.tags["Owner"], ["A1P2", "C1MP", "C3T1"])
    Compliance         = try(var.tags["Compliance"], ["None"])
    Order              = try(var.tags["Order"], "70039360")
  }
}
