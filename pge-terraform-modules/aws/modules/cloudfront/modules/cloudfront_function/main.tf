/*
 * # AWS CloudFront Function module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/cloudfront_function/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create a CloudFront function.
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

# CloudFront Functions in Amazon CloudFront, you can write lightweight functions in JavaScript for high-scale, latency-sensitive CDN customizations.
resource "aws_cloudfront_function" "cf_function" {

  name    = var.cf_function_name
  code    = var.cf_function_code
  runtime = "cloudfront-js-1.0"
  comment = var.cf_function_comment
  publish = var.cf_function_publish
}
