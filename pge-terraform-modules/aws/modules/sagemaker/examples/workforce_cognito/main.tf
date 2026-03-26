/*
* # AWS Sagemaker workforce
* # Terraform module which creates Sagemaker workforce
*/
#
# Filename     : aws/modules/sagemaker/modules/workforce/main.tf
# Date         : Sept 13 2022 
# Author       : TCS
# Description  : Terraform module example for creation of workforce_cognito in sagemaker
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
    cognito_config = {
      client_id = aws_cognito_user_pool_client.user_pool_client.id
      user_pool = aws_cognito_user_pool_domain.main.user_pool_id
    }
    oidc_config = {}
  }
  cidrs = var.cidrs
}

# Using aws_cognito resource to create user_pool and client_id for configuring cognito_config for the workforce. 
# When having values for client_id and user_pool the entire aws_cognito resource can be commented.
resource "aws_cognito_user_pool" "user_pool" {
  name = "tf-test-user"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name            = "tf-test-user-pool"
  generate_secret = true
  user_pool_id    = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "pgedomain"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}