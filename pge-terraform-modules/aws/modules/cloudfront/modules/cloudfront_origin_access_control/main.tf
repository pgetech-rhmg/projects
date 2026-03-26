/*
 * # AWS CloudFront origin access control module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/cloudfront_origin_access_control/main.tf
#  Date        : 23 june 2025
#  Author      : pge
#  Description : CloudFront terraform module to create a CloudFront origin access control resource.
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



resource "aws_cloudfront_origin_access_control" "default" {
  name                              = var.cloudfront_oac_name
  description                       = var.cloudfront_oac_description
  origin_access_control_origin_type = var.cloudfront_oac_origin_type
  signing_behavior                  = var.cloudfront_oac_signing_behavior
  signing_protocol                  = var.cloudfront_oac_signing_protocol
}