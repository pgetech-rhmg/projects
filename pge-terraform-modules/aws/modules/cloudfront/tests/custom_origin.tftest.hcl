run "custom_origin" {
  command = apply

  module {
    source = "./examples/custom_origin"
  }
}

variables {
  account_num                              = "750713712981"
  aws_region                               = "us-west-2"
  aws_role                                 = "CloudAdmin"
  AppID                                    = "1001"
  Environment                              = "Dev"
  DataClassification                       = "Internal"
  CRIS                                     = "Low"
  Notify                                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                    = ["abc1", "def2", "ghi3"]
  Compliance                               = ["None"]
  Order                                    = 8115205
  comment_cfd                              = "Cloudfront-distribution"
  default_root_object                      = "index.html"
  enabled                                  = true
  http_version                             = "http2"
  event_type                               = "viewer-request"
  df_cache_behavior_target_origin_id       = "cloudfrontalbtest"
  df_cache_behavior_allowed_methods        = ["GET", "HEAD"]
  df_cache_behavior_cached_methods         = ["GET", "HEAD"]
  df_cache_behavior_viewer_protocol_policy = "redirect-to-https"
  origin_id                                = "cloudfrontalbtest"
  origin_https_port                        = 443
  origin_protocol_policy                   = "https-only"
  origin_ssl_protocols                     = ["TLSv1.2"]
  custom_header_name                       = "X-Forwarded-Scheme"
  custom_header_value                      = "https"
  origin_shield_enabled                    = false
  origin_shield_region                     = "us-west-2"
  forwarded_values = [{
    query_string = false
    cookies = [{
      forward = "none"
    }]
  }]
  custom_error_response = [
    {
      error_caching_min_ttl = 1
      error_code            = 404
      response_code         = 200
      response_page_path    = "/"
    }
  ]
  geo_restriction = [{
    restriction_type = "whitelist",
    locations        = ["US", "CA"]
  }]
  viewer_certificate = [{
    acm_certificate_arn      = "arn:aws:acm:us-east-1:750713712981:certificate/63af2c92-c74a-456a-8788-43b9c3255d82"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }]
  key_group_name                                              = "test_key_group25"
  public_key_comment                                          = "test_key"
  realtime_metrics_subscription_status                        = "Enabled"
  kms_name                                                    = "test-iac2"
  kms_role                                                    = "TF_Developers"
  realtime_log_config_name                                    = "test_log_config25"
  realtime_log_config_sampling_rate                           = 10
  realtime_log_config_fields                                  = ["timestamp", "c-ip", "cs-headers"]
  realtime_log_config_stream_type                             = "Kinesis"
  encryption_profile_name                                     = "test_profile25"
  encryption_profile_provider_id                              = "test_provider"
  encryption_profile_items                                    = ["DateOfBirth"]
  encryption_config_content_type                              = "application/x-www-form-urlencoded"
  encryption_config_format                                    = "URLEncoded"
  encryption_config_forward_when_content_type_is_unknown      = true
  encryption_config_forward_when_query_arg_profile_is_unknown = true
  cf_function_name                                            = "test25"
  log_policy                                                  = "s3_log_policy.json"
  role_name                                                   = "test_cloudfront_role25"
  role_service                                                = ["cloudfront.amazonaws.com"]
  kinesis_stream_name                                         = "terraform-kinesis-test25"
  kinesis_stream_shard_count                                  = 1
  kinesis_stream_retention_period                             = 48
  kinesis_stream_mode                                         = "PROVISIONED"
  kinesis_stream_shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  log_bucket_name = "lanid-cloudfront-log"
  log_bucket_acl  = "private"
  cache_policy = [{
    name    = "cloudfront-cache-policy25"
    min_ttl = 60
    comment = "Testing the cloudfront cache policy"
    parameters_in_cache_key_and_forwarded_to_origin = [{
      cookies_config = [{
        cookie_behavior = "none"
      }]
      headers_config = [{
        header_behavior = "none"
      }]
      query_strings_config = [{
        query_string_behavior = "none"
      }]
    }]
  }]
  response_headers_policy = [{
    name = "cloudfront-response-header-policy25"
    cors_config = [{
      access_control_allow_credentials = true
      access_control_allow_headers = [{
        items = ["test"]
      }]
      access_control_allow_methods = [{
        items = ["GET"]
      }]
      access_control_allow_origins = [{
        items = ["test.example.comtest"]
      }]
      access_control_max_age_sec = 600
      origin_override            = true
    }]
    custom_headers_config = [{
      header   = "X-Permitted-Cross-Domain-Policies"
      override = true
      value    = "none"
    }]
    security_headers_config = [{
      content_security_policy = [{
        content_security_policy = "none"
        override                = false
      }]
      content_type_options = [{
        override = false
      }]
      frame_options = [{
        frame_option = "DENY"
        override     = false
      }]
      strict_transport_security = [{
        access_control_max_age_sec = 63072000
        include_subdomains         = true
        preload                    = true
        override                   = false
      }]
      xss_protection = [{
        mode_block : true
        protection : true
        override : false
      }]
    }]
  }]
  origin_request_policy = [{
    name = "test_origin_policy25"
    cookies_config = [{
      cookie_behavior = "whitelist"
      cookies = [{
        items = ["example"]
      }]
    }]
    headers_config = [{
      header_behavior = "whitelist"
      headers = [{
        items = ["example"]
      }]
    }]
    query_strings_config = [{
      query_string_behavior = "whitelist"
      query_strings = [{
        items = ["example"]
      }]
    }]
  }]
  webacl_name                = "test-wafv2-rule-iac-tf123425"
  webacl_description         = "test1234"
  cloudwatch_metrics_enabled = true
  sampled_requests_enabled   = true
  metric_name                = "metric-name"
  request_default_action     = "allow"
  managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet",
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList",
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet",
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet",
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet",
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesUnixRuleSet",
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    }
  ]
  redacted_fields = [
    {
      single_header = {
        name = "user-agent"
      }
    }
  ]
  waf_v2_logging_kinesis_s3_bucket_name = "tf-test-bucket-for-waf-v2-for-cf25"
  kinesis_iam_role_name                 = "firehose_test_role11234525"
  policy_arns                           = ["arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"]
  aws_service                           = ["firehose.amazonaws.com"]
  alb_name                              = "tf-lb-test25"
  lb_listener_https = [{
    port              = 443
    protocol          = "HTTPS"
    certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/94bee8ed-1fe1-44b3-9506-456ac855bb3d"
    target_group_name = "target-alb"
    type              = "forward"
  }]
  alb_s3_bucket_name                           = "alb-s3-logs-test25"
  policy                                       = "s3_alb_log_policy.json"
  ec2_name                                     = "test-02"
  ec2_instance_type                            = "t2.micro"
  ec2_az                                       = "us-west-2a"
  alb_sg_name                                  = "test-alb-sg25"
  alb_sg_description                           = "Security group for example usage with ec2"
  sg_name                                      = "test-ec2-alb-sg25"
  sg_description                               = "Security group for example usage with ec2"
  ec2_user_data                                = <<-EOT
    yum update -y
    amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
    yum install -y httpd mariadb-server
    systemctl start httpd
    systemctl enable httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
  EOT
  vpc_id_name                                  = "/vpc/id"
  subnet_id1_name                              = "/vpc/2/privatesubnet1/id"
  subnet_id3_name                              = "/vpc/privatesubnet3/id"
  golden_ami_name                              = "/ami/linux/golden"
  target_group_name                            = "target-alb"
  target_group_target_type                     = "instance"
  target_group_port                            = 80
  target_group_protocol                        = "HTTP"
  targets_port                                 = 80
  bucket_sse_algorithm                         = "AES256"
  kinesis_firehose_delivery_stream_destination = "extended_s3"
  aws_kinesis_firehose_delivery_stream_name    = "aws-waf-logs-test-iac-tf-2-cloudfront25"
}
