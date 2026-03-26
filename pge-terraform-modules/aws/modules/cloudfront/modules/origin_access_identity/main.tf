/*
 * # AWS CloudFront Orgin access identity module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/orgin_access_identity/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create  CloudFront Orgin access identity.
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

resource "aws_cloudfront_origin_access_identity" "cf_origin_access_identity" {
  comment = var.comment_cf_oai
}
