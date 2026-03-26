/*
 * # AWS CloudFront Field level encryption profile module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/security/field_level_encryption_profile/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create a CloudFront Field level encryption profile.
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
# This for_each condition helps to create multiple 'aws_cloudfront_field_level_encryption_profile'.
resource "aws_cloudfront_field_level_encryption_profile" "cf_field_level_encryption_profile" {
  for_each = { for value in var.cf_field_level_encryption_profile : value.name => value }

  name    = each.value.name
  comment = lookup(each.value, "comment", null)
  # The encryption_entities block is required.
  dynamic "encryption_entities" {
    for_each = each.value.encryption_entities
    content {
      dynamic "items" {
        for_each = encryption_entities.value.items
        content {
          public_key_id = items.value.public_key_id
          provider_id   = items.value.provider_id
          dynamic "field_patterns" {
            for_each = items.value.field_patterns
            content {
              items = field_patterns.value.items
            }
          }
        }
      }
    }
  }
}

