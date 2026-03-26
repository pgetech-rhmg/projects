data "aws_region" "current" {}
data "aws_canonical_user_id" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_arn" "sts" {
  arn = data.aws_caller_identity.current.arn
}
