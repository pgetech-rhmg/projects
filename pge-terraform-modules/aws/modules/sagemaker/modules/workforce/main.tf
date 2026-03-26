/*
* # AWS sagemaker workforce module
* # Terraform module which creates Sagemaker workforce
*/
#
# Filename     : aws/modules/sagemaker/modules/workforce/main.tf
# Date         : Sept 13 2022 
# Author       : TCS
# Description  : Terraform sub-module for creation of workforce in sagemaker
#

# Use this operation to create a workforce. This operation will return an error if a workforce already exists in the AWS Region that you specify. 
# You can only create one workforce in each AWS Region per AWS account.

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

resource "aws_sagemaker_workforce" "sagemaker_workforce" {
  workforce_name = var.workforce_name
  # cognito_config conflicts with oidc_config so the for_each condition looks for value of cognito_config and execute the below dynamic block.
  # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.   
  dynamic "cognito_config" {
    for_each = var.cognito_oidc.cognito_config != {} ? [var.cognito_oidc.cognito_config] : []
    content {
      client_id = cognito_config.value["client_id"]
      user_pool = cognito_config.value["user_pool"]
    }
  }

  # oidc_config conflicts with cognito_config so the for_each condition looks for value of oidc_config and executes the below dynamic block.
  # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.
  dynamic "oidc_config" {
    for_each = var.cognito_oidc.oidc_config != {} ? [var.cognito_oidc.oidc_config] : []
    content {
      authorization_endpoint = oidc_config.value["authorization_endpoint"]
      client_id              = oidc_config.value["client_id"]
      client_secret          = oidc_config.value["client_secret"]
      issuer                 = oidc_config.value["issuer"]
      jwks_uri               = oidc_config.value["jwks_uri"]
      logout_endpoint        = oidc_config.value["logout_endpoint"]
      token_endpoint         = oidc_config.value["token_endpoint"]
      user_info_endpoint     = oidc_config.value["user_info_endpoint"]
    }
  }

  source_ip_config {
    cidrs = var.cidrs
  }
}