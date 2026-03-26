/*
* # AWS Cognito identity pool usage example.
* Terraform module which creates SAF2.0 Cognito identity pool resources in AWS.
*/
#
# Filename    : modules/dms/examples/cognito-identity-pool/main.tf
# Date        : 30 July 2024
# Author      : PGE
# Description : The Terraform usage example creates aws cognito identity pool resources


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role

}



module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################################################################

module "cognito_identity_pool" {
  source                           = "../.."
  name                             = var.name
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  openid_connect_provider_arns     = var.openid_connect_provider_arns
  saml_provider_arns               = var.saml_provider_arns
  allow_classic_flow               = var.allow_classic_flow
  ##inline policy
  inline_policy = [data.aws_iam_policy_document.inline_policy.json]
  tags          = module.tags.tags

}

### please modify the below policy as per your requirement
data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]
    resources = ["*"]
  }
}
