#  Filename    : aws/modules/api-gateway/modules/custom_domain/main.tf
#  Date        : 22 Nov 2022
#  Author      : PGE
#  Description : Create API Gateway Custom Domain
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws, aws.r53, aws.us_east_1]
    }
  }
}

locals {
  namespace       = "ccoe-tf-developers"
  api_id          = var.api_id
  api_stage       = var.api_stage
  api_type        = var.api_type
  sub_domain_name = var.sub_domain_name

  custom_domain_name = "${local.api_id}.${local.api_type == "Internal" ? "internal." : ""}${data.aws_region.current.name}.${local.sub_domain_name}.pge.com"

  base_domain_name          = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", local.custom_domain_name)[1]
  external_base_domain_list = ["alerts.pge.com", "ccare.pge.com", "cloudapi.pge.com", "dc.pge.com", "dcs.pge.com", "digitalcatalyst.pge.com", "io.pge.com", "ss-dev.pge.com", "ss.pge.com"]

  d_account_id = data.aws_arn.sts.account
  d_resource   = data.aws_arn.sts.resource
  d_role       = split("/", local.d_resource)[1]
}

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.0"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name = local.custom_domain_name
  tags            = merge(var.tags, { pge_team = local.namespace })
}

resource "aws_api_gateway_domain_name" "custom_domain" {
  provider                 = aws
  depends_on               = [module.acm_public_certificate]
  domain_name              = local.custom_domain_name
  regional_certificate_arn = module.acm_public_certificate.acm_certificate_arn
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = merge(var.tags, { pge_team = local.namespace })
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  provider    = aws
  depends_on  = [module.acm_public_certificate, aws_api_gateway_domain_name.custom_domain]
  api_id      = local.api_id
  domain_name = local.custom_domain_name
  stage_name  = local.api_stage
}