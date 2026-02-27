resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "pge-epic-${var.app_name}-${var.environment}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_request_policy" "spa_origin_policy" {
  name    = "${var.bucket_name}-spa-origin-policy"
  comment = "Origin request policy for SPA"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_response_headers_policy" "cors" {
  name    = "pge-epic-${var.app_name}-${var.environment}-cors-policy"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    }

    access_control_allow_origins {
      items = var.cors_allowed_origins
    }

    origin_override = true
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  depends_on = [
    aws_cloudfront_origin_access_control.oac,
    aws_cloudfront_origin_request_policy.spa_origin_policy
  ]

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "${var.bucket_name}-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id         = "${var.bucket_name}-origin"
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = aws_cloudfront_origin_request_policy.spa_origin_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = var.price_class
  aliases     = length(var.custom_domain_aliases) > 0 ? var.custom_domain_aliases : null

  dynamic "viewer_certificate" {
    for_each = local.use_custom_cert ? [1] : []
    content {
      acm_certificate_arn      = var.custom_acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.use_custom_cert ? [] : [1]
    content {
      cloudfront_default_certificate = true
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  tags = var.tags
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = var.bucket_name
  depends_on = [
    aws_cloudfront_distribution.cdn
  ]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = ["s3:GetObject"]
        Resource = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}
