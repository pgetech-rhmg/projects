/*
 * # AWS CloudFront module Field level encryption configurations
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/field_level_encryption_config/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create Field level encryption configurations.
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
# This for_each condition helps to create multiple 'aws_cloudfront_field_level_encryption_config'.
resource "aws_cloudfront_field_level_encryption_config" "cf_field_level_encryption_config" {
  for_each = { for index, value in var.cf_field_level_encryption_config : index => value }
  comment  = lookup(each.value, "comment", null)

  # The content_type_profile_config block is required.
  dynamic "content_type_profile_config" {
    for_each = each.value.content_type_profile_config
    content {
      forward_when_content_type_is_unknown = content_type_profile_config.value.forward_when_content_type_is_unknown
      dynamic "content_type_profiles" {
        for_each = content_type_profile_config.value.content_type_profiles
        content {
          dynamic "items" {
            for_each = content_type_profiles.value.items
            content {
              content_type = items.value.content_type
              format       = items.value.format
              profile_id   = lookup(items.value, "profile_id", null)
            }
          }
        }
      }
    }
  }

  # The query_arg_profile_config block is required. 
  dynamic "query_arg_profile_config" {
    for_each = each.value.query_arg_profile_config
    content {
      forward_when_query_arg_profile_is_unknown = query_arg_profile_config.value.forward_when_query_arg_profile_is_unknown
      # The query_arg_profiles block is optional. 
      dynamic "query_arg_profiles" {
        for_each = lookup(query_arg_profile_config.value, "query_arg_profiles", {})
        content {
          dynamic "items" {
            for_each = query_arg_profiles.value.items
            content {
              profile_id = items.value.profile_id
              query_arg  = items.value.query_arg
            }
          }
        }
      }
    }
  }
}
