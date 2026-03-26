/*
 * # AWS CloudFront Custom Orgin module
 * Terraform module which creates SAF2.0 CloudFront in AWS
*/

#
#  Filename    : aws/modules/cloudfront/modules/cloudfront_custom_origin/main.tf
#  Date        : 22 april 2022
#  Author      : TCS
#  Description : CloudFront terraform module to create a CloudFront custom origin.
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

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_cloudfront_distribution" "cf_distribution" {

  aliases             = var.aliases
  comment             = var.comment_cfd
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version

  # The condition will loop over the variable custom_error_response and fetch the argument values for this resource
  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_code            = custom_error_response.value.error_code
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  default_cache_behavior {

    allowed_methods           = var.df_cache_behavior_allowed_methods
    cached_methods            = var.df_cache_behavior_cached_methods
    cache_policy_id           = var.df_cache_behavior_cache_policy_id
    default_ttl               = var.df_cache_behavior_default_ttl
    compress                  = var.df_cache_behavior_compress
    field_level_encryption_id = var.df_cache_behavior_field_level_encryption_id
    target_origin_id          = var.df_cache_behavior_target_origin_id

    # The condition will loop over the variable lambda_function_association and fetch the argument values for this resource
    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lookup(lambda_function_association, "include_body", false)
      }
    }

    # The condition will loop over the variable function_association and fetch the argument values for this resource
    dynamic "function_association" {
      for_each = var.function_association
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    max_ttl                    = var.df_cache_behavior_max_ttl
    min_ttl                    = var.df_cache_behavior_min_ttl
    origin_request_policy_id   = var.df_cache_behavior_origin_request_policy_id
    realtime_log_config_arn    = var.df_cache_behavior_realtime_log_config_arn
    response_headers_policy_id = var.df_cache_behavior_response_headers_policy_id
    smooth_streaming           = var.df_cache_behavior_smooth_streaming
    trusted_key_groups         = var.df_cache_behavior_trusted_key_groups
    trusted_signers            = var.df_cache_behavior_trusted_signers
    viewer_protocol_policy     = var.df_cache_behavior_viewer_protocol_policy

    # The condition will loop over the variable forwarded_values and fetch the argument values for this resource
    dynamic "forwarded_values" {
      for_each = var.forwarded_values
      content {
        headers                 = lookup(forwarded_values.value, "headers", null)
        query_string            = forwarded_values.value.query_string
        query_string_cache_keys = lookup(forwarded_values.value, "query_string_cache_keys", null)

        dynamic "cookies" {
          for_each = forwarded_values.value.cookies
          content {
            forward           = cookies.value.forward
            whitelisted_names = lookup(cookies.value, "whitelisted_names", null)
          }
        }
      }
    }
  }

  # The condition will loop over the variable logging_config and fetch the argument values for this resource
  dynamic "logging_config" {
    for_each = var.logging_config
    content {
      bucket          = logging_config.value.bucket
      include_cookies = lookup(logging_config.value, "include_cookies", null)
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  # The condition will loop over the variable origin_group and fetch the argument values for this resource
  dynamic "origin_group" {
    for_each = var.origin_group
    content {
      origin_id = origin_group.value.origin_id

      dynamic "failover_criteria" {
        for_each = origin_group.value.failover_criteria
        content {
          status_codes = failover_criteria.value.status_codes
        }
      }
      dynamic "member" {
        for_each = origin_group.value.primary_origin
        content {
          origin_id = member.value.origin_id
        }
      }
      dynamic "member" {
        for_each = origin_group.value.secondary_origin
        content {
          origin_id = member.value.origin_id
        }
      }
    }
  }

  price_class         = var.price_class
  web_acl_id          = var.web_acl_id
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  # The condition will loop over the variable origin and fetch the argument values for this resource
  dynamic "origin" {
    for_each = var.origin

    content {
      connection_attempts = lookup(origin.value, "connection_attempts", 3)
      connection_timeout  = lookup(origin.value, "connection_timeout", 10)
      domain_name         = origin.value.domain_name
      origin_id           = origin.value.origin_id
      origin_path         = lookup(origin.value, "origin_path", null)

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config

        content {
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 60)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 60)
          http_port                = lookup(custom_origin_config.value, "http_port", 80)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", {})

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = lookup(origin_shield.value, "origin_shield_region", null)
        }
      }
    }
  }

  # The condition will loop over the variable ordered_cache_behavior and fetch the argument values for this resource
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior

    content {
      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      path_pattern              = ordered_cache_behavior.value.path_pattern
      target_origin_id          = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy    = ordered_cache_behavior.value.viewer_protocol_policy
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id

      cache_policy_id            = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      compress                   = lookup(ordered_cache_behavior.value, "compress", false)
      default_ttl                = lookup(ordered_cache_behavior.value, "default_ttl", null)
      max_ttl                    = lookup(ordered_cache_behavior.value, "max_ttl", null)
      min_ttl                    = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      origin_request_policy_id   = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      realtime_log_config_arn    = lookup(ordered_cache_behavior.value, "realtime_log_config_arn", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)
      smooth_streaming           = lookup(ordered_cache_behavior.value, "smooth_streaming", null)
      trusted_key_groups         = lookup(ordered_cache_behavior.value, "trusted_key_groups", null)
      trusted_signers            = lookup(ordered_cache_behavior.value, "trusted_signers", null)

      # This is an optional block and will enable if values are provided in the variable ordered_cache_behavior.
      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_association", {})
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lookup(lambda_function_association.value, "include_body", false)
        }
      }

      # This is an optional block and will enable if values are provided in the variable ordered_cache_behavior.
      dynamic "function_association" {
        for_each = lookup(ordered_cache_behavior.value, "function_association", {})
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      # This is an optional block and will enable if values are provided in the variable ordered_cache_behavior.
      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "forwarded_values", {})
        content {
          headers                 = lookup(forwarded_values.value, "headers", null)
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = lookup(forwarded_values.value, "query_string_cache_keys", null)

          dynamic "cookies" {
            for_each = forwarded_values.value.cookies
            content {
              forward           = cookies.value.forward
              whitelisted_names = lookup(cookies.value, "whitelisted_names", null)
            }
          }
        }
      }
    }
  }

  restrictions {
    # The condition will loop over the variable ordered_cache_behavior and fetch the argument values for this resource
    dynamic "geo_restriction" {
      for_each = var.geo_restriction
      content {
        locations        = lookup(geo_restriction.value, "locations", null)
        restriction_type = geo_restriction.value.restriction_type
      }
    }
  }

  # The condition will loop over the variable ordered_cache_behavior and fetch the argument values for this resource
  dynamic "viewer_certificate" {
    for_each = var.viewer_certificate
    content {
      acm_certificate_arn      = lookup(viewer_certificate.value, "acm_certificate_arn", null)
      iam_certificate_id       = lookup(viewer_certificate.value, "iam_certificate_id", null)
      ssl_support_method       = lookup(viewer_certificate.value, "ssl_support_method", null)
      minimum_protocol_version = lookup(viewer_certificate.value, "minimum_protocol_version", "TLSv1.2")
    }
  }

  tags = local.module_tags
}

# The condition will process the variable cf_monitoring_subscription and loop over the resource.
# This for_each condition helps to create multiple 'aws_cloudfront_monitoring_subscription'.
resource "aws_cloudfront_monitoring_subscription" "cf_monitoring_subscription" {
  for_each        = { for index, value in var.cf_monitoring_subscription : index => value }
  distribution_id = each.value.distribution_id
  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = each.value.realtime_metrics_subscription_status
    }
  }
}

# The condition will process the variable cf_realtime_log_config and loop over the resource.
# This for_each condition helps to create multiple 'aws_cloudfront_realtime_log_config'.
resource "aws_cloudfront_realtime_log_config" "cf_realtime_log_config" {
  for_each = { for value in var.cf_realtime_log_config : value.name => value }

  name          = each.value.name
  sampling_rate = each.value.sampling_rate
  fields        = each.value.fields

  dynamic "endpoint" {
    for_each = each.value.endpoint
    content {
      stream_type = endpoint.value.stream_type

      # This is a required block and this block will fetch the values from the variable cf_realtime_log_config.
      dynamic "kinesis_stream_config" {
        for_each = endpoint.value.kinesis_stream_config
        content {
          role_arn   = kinesis_stream_config.value.role_arn
          stream_arn = kinesis_stream_config.value.stream_arn
        }
      }
    }
  }
}