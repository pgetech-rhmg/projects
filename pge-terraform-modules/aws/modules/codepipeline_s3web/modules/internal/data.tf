data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      var.codepipeline_type != "custom" ? module.s3[0].arn : "",
      var.codepipeline_type != "custom" ? "${module.s3[0].arn}/*" : ""
    ]
  }
}

data "aws_s3_bucket" "s3web" {
  bucket = var.s3_static_web_bucket_name
}

# data "aws_s3_bucket" "artifact_store_location_bucket" {
#   count = var.artifact_store_location_bucket != null ? 1 : 0
#   bucket = var.artifact_store_location_bucket
# }