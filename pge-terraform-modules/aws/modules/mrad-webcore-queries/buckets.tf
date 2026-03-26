module "ecs_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name   = "${local.queries_resource_name}"
  kms_key_arn   = data.aws_kms_key.s3.arn
  force_destroy = true
  tags          = var.tags
}

module "lb_log_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name = "${local.queries_resource_name}-lb-logs"
  policy      = data.aws_iam_policy_document.lb_logs_policy_doc.json
  # load balancers in AWS do not support customer managed keys
  force_destroy = true
  tags          = var.tags
}
