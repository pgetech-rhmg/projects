/*
 * # AWS CloudFront Policy module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/cloudfront_policy/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create CloudFront policies.
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

# The following resource below creates a CloudFront cache policy. The cache policy will be disabled by default,
# and it wil be enabled when the user gives value to the resource. The user can also create multiple cache policies.
resource "aws_cloudfront_cache_policy" "cf_cache_policy" {
  for_each = { for value in var.cache_policy : value.name => value }

  name        = each.value.name
  min_ttl     = each.value.min_ttl
  max_ttl     = lookup(each.value, "max_ttl", null)
  default_ttl = lookup(each.value, "default_ttl", null)
  comment     = lookup(each.value, "comment", null)

  # This is an optional block and this block will fetch the values from the variable cache_policy.
  dynamic "parameters_in_cache_key_and_forwarded_to_origin" {
    for_each = lookup(each.value, "parameters_in_cache_key_and_forwarded_to_origin")
    content {
      dynamic "cookies_config" {
        for_each = parameters_in_cache_key_and_forwarded_to_origin.value.cookies_config

        content {
          cookie_behavior = cookies_config.value.cookie_behavior
          dynamic "cookies" {
            for_each = lookup(cookies_config.value, "cookies", {})

            content {
              items = cookies.value.items
            }
          }
        }
      }

      # This is a required block and this block will fetch the values from the variable cache_policy.
      dynamic "headers_config" {
        for_each = parameters_in_cache_key_and_forwarded_to_origin.value.headers_config
        content {
          header_behavior = headers_config.value.header_behavior

          dynamic "headers" {
            for_each = lookup(headers_config.value, "headers", {})
            content {
              items = headers.value.items
            }
          }
        }
      }

      # This is a required block and this block will fetch the values from the variable cache_policy.
      dynamic "query_strings_config" {
        for_each = parameters_in_cache_key_and_forwarded_to_origin.value.query_strings_config
        content {
          query_string_behavior = query_strings_config.value.query_string_behavior
          dynamic "query_strings" {
            for_each = lookup(query_strings_config.value, "headers", {})
            content {
              items = query_strings.value.items
            }
          }
        }
      }
      enable_accept_encoding_brotli = lookup(each.value, "enable_accept_encoding_brotli", null)
      enable_accept_encoding_gzip   = lookup(each.value, "enable_accept_encoding_gzip", null)
    }
  }
}

# The response_headers_check checks if there is cors_config, custom_headers_config, security_headers_config is present in
# the resource aws_cloudfront_response_headers_policy. If the following code blocks cors_config, custom_headers_config,
# security_headers_config are not provided, then the resource aws_cloudfront_response_headers_policy will not execute. 
locals {
  response_headers_check = flatten([[for value in var.response_headers_policy : [for ind, val in value : true if ind == "cors_config"]],
    [for value in var.response_headers_policy : [for ind, val in value : true if ind == "custom_headers_config"]],
  [for value in var.response_headers_policy : [for ind, val in value : true if ind == "security_headers_config"]]])
}

# The following resource below creates a CloudFront response headers policy. The response headers policy will be disabled by default,
# and it wil be enabled when the user gives value to the resource. The user can also create multiple response headers policies.
#aws_cloudfront_response_headers_policy
resource "aws_cloudfront_response_headers_policy" "cf__response_headers_policy" {
  for_each = { for value in var.response_headers_policy : value.name => value if local.response_headers_check != [] }

  name    = each.value.name
  comment = lookup(each.value, "comment", null)


  # This is an optional block and this block will fetch the values from the variable response_headers_policy.
  dynamic "cors_config" {
    for_each = lookup(each.value, "cors_config", {})
    content {
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials
      # This is a required block and this block will fetch the values from the variable response_headers_policy.
      dynamic "access_control_allow_headers" {
        for_each = cors_config.value.access_control_allow_headers
        content {
          items = access_control_allow_headers.value.items
        }
      }
      # This is a required block and this block will fetch the values from the variable response_headers_policy.
      dynamic "access_control_allow_methods" {
        for_each = cors_config.value.access_control_allow_methods
        content {
          items = access_control_allow_methods.value.items
        }
      }
      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "access_control_allow_origins" {
        for_each = lookup(cors_config.value, "access_control_allow_origins", {})
        content {
          items = access_control_allow_origins.value.items
        }
      }
      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "access_control_expose_headers" {
        for_each = lookup(cors_config.value, "access_control_expose_headers", {})
        content {
          items = access_control_expose_headers.value.items
        }
      }

      access_control_max_age_sec = cors_config.value.access_control_max_age_sec
      origin_override            = cors_config.value.origin_override
    }
  }

  # This is an optional block and this block will fetch the values from the variable response_headers_policy.
  dynamic "custom_headers_config" {
    for_each = lookup(each.value, "custom_headers_config", {})
    content {
      items {
        header   = custom_headers_config.value.header
        override = custom_headers_config.value.override
        value    = custom_headers_config.value.value
      }
    }
  }

  # This is an optional block and this block will fetch the values from the variable response_headers_policy.
  dynamic "security_headers_config" {
    for_each = lookup(each.value, "security_headers_config", {})
    content {
      dynamic "content_security_policy" {
        for_each = lookup(security_headers_config.value, "content_security_policy", {})
        content {
          content_security_policy = content_security_policy.value.content_security_policy
          override                = content_security_policy.value.override
        }
      }

      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "content_type_options" {
        for_each = lookup(security_headers_config.value, "content_type_options", {})
        content {
          override = content_type_options.value.override
        }
      }

      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "frame_options" {
        for_each = lookup(security_headers_config.value, "frame_options", {})
        content {
          frame_option = frame_options.value.frame_option
          override     = frame_options.value.override
        }
      }

      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "referrer_policy" {
        for_each = lookup(security_headers_config.value, "referrer_policy", {})
        content {
          referrer_policy = referrer_policy.value.referrer_policy
          override        = referrer_policy.value.override
        }
      }

      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "strict_transport_security" {
        for_each = lookup(security_headers_config.value, "strict_transport_security", {})
        content {
          access_control_max_age_sec = strict_transport_security.value.access_control_max_age_sec
          include_subdomains         = lookup(strict_transport_security.value, "include_subdomains", null)
          override                   = strict_transport_security.value.override
          preload                    = lookup(strict_transport_security.value, "preload", null)
        }
      }

      # This is an optional block and this block will fetch the values from the variable response_headers_policy.
      dynamic "xss_protection" {
        for_each = lookup(security_headers_config.value, "xss_protection", {})
        content {
          mode_block = xss_protection.value.mode_block
          override   = xss_protection.value.override
          protection = xss_protection.value.protection
          report_uri = lookup(xss_protection.value, "report_uri", null)
        }
      }
    }
  }
}


# The following resource below creates a CloudFront origin request policy. The origin request policy will be disabled by default,
# and it wil be enabled when the user gives value to the resource. The user can also create multiple origin request policies.
# aws_cloudfront_origin_request_policy 
resource "aws_cloudfront_origin_request_policy" "cf_origin_request_policy" {
  for_each = { for value in var.origin_request_policy : value.name => value }

  name    = each.value.name
  comment = lookup(each.value, "comment", null)

  # This is a required block and this block will fetch the values from the variable origin_request_policy.
  dynamic "cookies_config" {
    for_each = each.value.cookies_config
    content {
      cookie_behavior = cookies_config.value.cookie_behavior
      dynamic "cookies" {
        for_each = lookup(cookies_config.value, "cookies", {})
        content {
          items = cookies.value.items
        }
      }
    }
  }

  # This is a required block and this block will fetch the values from the variable origin_request_policy.
  dynamic "headers_config" {
    for_each = each.value.headers_config
    content {
      header_behavior = headers_config.value.header_behavior

      dynamic "headers" {
        for_each = lookup(headers_config.value, "headers", {})
        content {
          items = headers.value.items
        }
      }
    }
  }

  # This is a required block and this block will fetch the values from the variable origin_request_policy.
  dynamic "query_strings_config" {
    for_each = each.value.query_strings_config
    content {
      query_string_behavior = query_strings_config.value.query_string_behavior

      dynamic "query_strings" {
        for_each = lookup(query_strings_config.value, "query_strings", {})
        content {
          items = query_strings.value.items
        }
      }
    }
  }
}