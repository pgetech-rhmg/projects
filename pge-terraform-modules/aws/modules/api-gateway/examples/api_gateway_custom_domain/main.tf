#  Filename    : aws/examples/api-gateway/modules/custom_domain/main.tf
#  Date        : 22 Nov 2022
#  Author      : PGE
#  Description : Create API Gateway Custom Domain
#

locals {
  namespace                 = "ccoe-tf-developers"
  api_id                    = var.api_id
  api_stage                 = var.api_stage
  api_type                  = var.api_type
  sub_domain_name           = var.sub_domain_name

  r53_aws_role       = var.aws_r53_role
  r53_account_num    = var.account_num_r53

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

locals {
  d_account_id = data.aws_arn.sts.account
  d_resource   = data.aws_arn.sts.resource
  d_role       = split("/", local.d_resource)[1]
}


module "api_gateway_custom_domain" {
  source              = "../../modules/api_gateway_custom_domain"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
    aws.r53       = aws.r53
  }

  api_id              = local.api_id
  api_stage           = local.api_stage
  api_type            = local.api_type
  sub_domain_name     = local.sub_domain_name
  tags                = module.tags.tags

}