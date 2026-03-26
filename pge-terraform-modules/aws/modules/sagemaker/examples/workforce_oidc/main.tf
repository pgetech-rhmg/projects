/*
* # AWS Sagemaker workforce
* # Terraform module which creates Sagemaker workforce
*/
#
# Filename     : aws/modules/sagemaker/modules/workforce/main.tf
# Date         : Sept 13 2022 
# Author       : TCS
# Description  : Terraform module example for creation of workforce_oidc in sagemaker
#

locals {
  name = "${var.name}-${random_string.name.result}"
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "sagemaker_workforce" {
  source = "../../modules/workforce"

  workforce_name = local.name
  cognito_oidc = {
    cognito_config = {}
    oidc_config = {
      authorization_endpoint = "https://example.com"
      client_id              = "example"
      client_secret          = "example"
      issuer                 = "https://example.com"
      jwks_uri               = "https://example.com"
      logout_endpoint        = "https://example.com"
      token_endpoint         = "https://example.com"
      user_info_endpoint     = "https://example.com"
    }
  }
  cidrs = var.cidrs
}