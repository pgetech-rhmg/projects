/*
 * # AWS ACM Private CA User module example
*/
#
#  Filename    : aws/modules/acm/examples/acm_private_ca/main.tf
#  Date        : 30 March 2022
#  Author      : TCS
#  Description : Terraform module that creates an ACM


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
#########################################
# Create Acm
#########################################

module "acm_private_ca" {
  source = "../../modules/acm_private_ca"

  acm_domain_name               = var.acm_domain_name
  acm_certificate_authority_arn = aws_acmpca_certificate_authority.example.arn
  tags                          = merge(module.tags.tags, local.optional_tags)
  depends_on                    = [aws_acmpca_certificate_authority_certificate.example]
}

resource "aws_acmpca_certificate_authority_certificate" "example" {

  certificate_authority_arn = aws_acmpca_certificate_authority.example.arn
  certificate               = aws_acmpca_certificate.example.certificate
}

resource "aws_acmpca_certificate" "example" {

  certificate_authority_arn   = aws_acmpca_certificate_authority.example.arn
  certificate_signing_request = aws_acmpca_certificate_authority.example.certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"
  template_arn                = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"
  validity {
    type  = "YEARS"
    value = 2
  }
}

resource "aws_acmpca_certificate_authority" "example" {

  type = "ROOT"
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"
    subject {
      common_name = "example.com"
    }
  }
  tags = module.tags.tags
}

data "aws_partition" "current" {}