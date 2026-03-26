/*
 * # AWS CloudFront Key management module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/key_management/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create a CloudFront key management.
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




# The condition will process the variable and loop over the resource.
# This for_each condition helps to create multiple 'aws_cloudfront_public_key'.
resource "aws_cloudfront_public_key" "cf_public_key" {
  for_each = { for index, value in var.cf_public_key : index => value }

  comment     = lookup(each.value, "comment", null)
  encoded_key = each.value.encoded_key
  name        = lookup(each.value, "name", null)
}

# The condition will process the variable and loop over the resource.
# This for_each condition helps to create multiple 'aws_cloudfront_key_group'.
resource "aws_cloudfront_key_group" "cf_key_group" {
  for_each = { for index, value in var.cf_key_group : index => value }

  comment = lookup(each.value, "comment", null)
  items   = each.value.items
  name    = each.value.name
}
