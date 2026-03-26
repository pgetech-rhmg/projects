account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

# Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 # Order must be between 7 and 9 digits


##### aws_cloudfront_distribution###
comment_cfd                              = "Cloudfront-distribution"
default_root_object                      = "index.html"
enabled                                  = true
http_version                             = "http2"
event_type                               = "viewer-request"
df_cache_behavior_target_origin_id       = "cloudfrontalbtest"
df_cache_behavior_allowed_methods        = ["GET", "HEAD"]
df_cache_behavior_cached_methods         = ["GET", "HEAD"]
df_cache_behavior_viewer_protocol_policy = "redirect-to-https"

# origin
origin_id              = "cloudfrontalbtest"
origin_https_port      = 443
origin_protocol_policy = "https-only"
origin_ssl_protocols   = ["TLSv1.2"]

custom_header_name  = "X-Forwarded-Scheme"
custom_header_value = "https"

origin_shield_enabled = false
origin_shield_region  = "us-west-2"

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

# aws_cloudfront_key_group
key_group_name = "test_key_group25"

# aws_cloudfront_public_key
public_key_comment = "test_key"

# cf_monitoring_subscription
realtime_metrics_subscription_status = "Enabled"

# Variables for kms
kms_name = "test-iac2"
kms_role = "TF_Developers"

# aws_cloudfront_realtime_log_config
realtime_log_config_name          = "test_log_config25"
realtime_log_config_sampling_rate = 10
realtime_log_config_fields        = ["timestamp", "c-ip", "cs-headers"]
realtime_log_config_stream_type   = "Kinesis"

# aws_cloudfront_field_level_encryption_profile
encryption_profile_name        = "test_profile25"
encryption_profile_provider_id = "test_provider"
encryption_profile_items       = ["DateOfBirth"]

# aws_cloudfront_field_level_encryption_config
encryption_config_content_type                              = "application/x-www-form-urlencoded"
encryption_config_format                                    = "URLEncoded"
encryption_config_forward_when_content_type_is_unknown      = true
encryption_config_forward_when_query_arg_profile_is_unknown = true


# cloudfront_function###########################################
cf_function_name = "test25"

# s3#############################################################
log_policy = "s3_log_policy.json"

# iam_role for aws_cloudfront_realtime_log_config################
role_name    = "test_cloudfront_role25"
role_service = ["cloudfront.amazonaws.com"]

# aws_kinesis_stream########################################
kinesis_stream_name             = "terraform-kinesis-test25"
kinesis_stream_shard_count      = 1
kinesis_stream_retention_period = 48
kinesis_stream_mode             = "PROVISIONED"
kinesis_stream_shard_level_metrics = [
  "IncomingBytes",
  "OutgoingBytes",
]

# log_bucket_name###########################################
log_bucket_name = "lanid-cloudfront-log"
log_bucket_acl  = "private"

# aws_cloudfront_cache_policy#################################
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

# aws_cloudfront_response_headers_policy###########################
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

# cloudfront_origin_request_policy############################  
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

# waf##############################################################
webacl_name        = "test-wafv2-rule-iac-tf123425"
webacl_description = "test1234"

cloudwatch_metrics_enabled = true
sampled_requests_enabled   = true
metric_name                = "metric-name"

request_default_action = "allow"

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

# Values for aws_wafv2_web_acl_logging_configuration
redacted_fields = [
  {
    single_header = {
      name = "user-agent"
    }
  }
]

# Values for aws_wafv2_web_acl_logging
waf_v2_logging_kinesis_s3_bucket_name = "tf-test-bucket-for-waf-v2-for-cf25"

# Values for iam role
kinesis_iam_role_name = "firehose_test_role11234525"
policy_arns           = ["arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"]
aws_service           = ["firehose.amazonaws.com"]

# alb###############################################################
alb_name = "tf-lb-test25"
lb_listener_https = [{
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/94bee8ed-1fe1-44b3-9506-456ac855bb3d"
  target_group_name = "target-alb"
  type              = "forward"
}]

# s3
alb_s3_bucket_name = "alb-s3-logs-test25"
policy             = "s3_alb_log_policy.json"

# Ec2 variables
ec2_name          = "test-02"
ec2_instance_type = "t2.micro"
ec2_az            = "us-west-2a"

# Security group variables
alb_sg_name        = "test-alb-sg25"
alb_sg_description = "Security group for example usage with ec2"

sg_name        = "test-ec2-alb-sg25"
sg_description = "Security group for example usage with ec2"

# ec2_user_data
ec2_user_data = <<-EOT
    #!/bin/bash
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

# parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
subnet_id3_name = "/vpc/privatesubnet3/id"
golden_ami_name = "/ami/linux/golden"

# lb_target_group
target_group_name        = "target-alb"
target_group_target_type = "instance"
target_group_port        = 80
target_group_protocol    = "HTTP"
targets_port             = 80

# aws_s3_bucket_server_side_encryption_configuration
bucket_sse_algorithm = "AES256"

# aws_kinesis_firehose_delivery_stream
kinesis_firehose_delivery_stream_destination = "extended_s3"
aws_kinesis_firehose_delivery_stream_name    = "aws-waf-logs-test-iac-tf-2-cloudfront25"