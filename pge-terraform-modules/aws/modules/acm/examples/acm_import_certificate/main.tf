/*
 * # AWS ACM Import existing certificate User module example
*/
#
#  Filename    : aws/modules/acm/examples/acm_import_certificate/main.tf
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

module "acm_import_certificate" {
  source = "../../modules/acm_import_certificate"

  acm_private_key      = tls_private_key.example.private_key_pem
  acm_certificate_body = tls_self_signed_cert.example.cert_pem
  tags                 = merge(module.tags.tags, local.optional_tags)
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
