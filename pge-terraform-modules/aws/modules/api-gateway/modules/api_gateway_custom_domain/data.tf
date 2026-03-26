data "aws_region" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_caller_identity" "current" {}

data "aws_arn" "sts" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_route53_zone" "public_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = false
}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = true
}


data "aws_region" "east1" {
  provider = aws.us_east_1
}