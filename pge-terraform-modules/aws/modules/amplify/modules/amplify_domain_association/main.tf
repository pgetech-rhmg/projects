/*
 * # AWS Amplify Domain Association module.
 * Terraform module which creates SAF2.0 Amplify Domain Association in AWS.
*/

#
#  Filename    : aws/modules/amplify/modules/amplify_domain_association/main.tf
#  Date        : 4 October 2022
#  Author      : TCS
#  Description : Amplify Domain Association Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Amplify Domain Association
# Description : This terraform module creates an Amplify Domain Association.

resource "aws_amplify_domain_association" "amplify_domain_association" {

  app_id      = var.app_id
  domain_name = var.domain_name
  dynamic "sub_domain" {
    for_each = var.sub_domain
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }
  wait_for_verification = var.wait_for_verification
}