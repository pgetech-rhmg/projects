resource "aws_acm_certificate" "default" {
  count             = var.certificate_type == "default" ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "public" {
  count             = var.certificate_type == "public" ? 1 : 0
  provider          = aws.us_east_1

  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  certificate_arn             = var.certificate_type == "public" ? aws_acm_certificate.public[0].arn : aws_acm_certificate.default[0].arn
  domain_validation_options   = var.certificate_type == "public" ? aws_acm_certificate.public[0].domain_validation_options : aws_acm_certificate.default[0].domain_validation_options
}

module "aws_route53_record" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  target_zone_id            = var.public_hosted_zone_id
  domain_validation_options = local.domain_validation_options
}

resource "aws_acm_certificate_validation" "default" {
  count                   = var.certificate_type == "default" ? 1 : 0

  certificate_arn         = local.certificate_arn
  validation_record_fqdns = module.aws_route53_record.validation_record_fqdns
}

resource "aws_acm_certificate_validation" "public" {
  count                   = var.certificate_type == "public" ? 1 : 0
  provider                = aws.us_east_1

  certificate_arn         = local.certificate_arn
  validation_record_fqdns = module.aws_route53_record.validation_record_fqdns
}
