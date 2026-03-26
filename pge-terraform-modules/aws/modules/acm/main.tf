/*
 * # AWS ACM module creating public certificate
 * Terraform module which creates SAF2.0 ACM in AWS.
 * This module will handle the record creation in Route53 if acm_r53update_validate is set to true.By default, it will launch into public zone of r53 account.
*/
#
# Filename    : aws/modules/acm/main.tf
# Date        : 28/03/2022
# Author      : TCS
# Description : AWS Certificate Manager module main
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws, aws.r53]
    }
  }
}

locals {
  acm_r53update_validate = var.acm_r53update_validate ? aws_acm_certificate.acm_certificate.domain_validation_options : toset([])
  namespace              = "ccoe-tf-developers"
  base_domain_name       = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.acm_domain_name)[1]
}

data "aws_route53_zone" "public_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = false
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  validation_method         = "DNS"
  tags                      = local.module_tags

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "acm_r53record_update" {
  provider = aws.r53
  for_each = {
    for dvo in local.acm_r53update_validate : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = var.allow_overwrite
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public_zone.zone_id
}


resource "aws_acm_certificate_validation" "certificate_validation" {
  count                   = var.acm_r53update_validate ? 1 : 0
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = var.acm_validation_record_fqdns

  timeouts {
    create = var.acm_validation_create_timeouts
  }
  depends_on = [
    aws_route53_record.acm_r53record_update
  ]
}

