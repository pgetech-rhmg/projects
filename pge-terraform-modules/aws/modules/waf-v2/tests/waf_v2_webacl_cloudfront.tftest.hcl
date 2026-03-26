run "waf_v2_webacl_cloudfront" {
  command = apply

  module {
    source = "./examples/waf_v2_webacl_cloudfront"
  }
}

variables {
  aws_region                      = "us-west-2"
  account_num                     = "750713712981"
  aws_role                        = "CloudAdmin"
  kms_role                        = "CloudAdmin"
  kms_name                        = "lanid-waf-v2-s3-bucket"
  kms_description                 = "CMK for encrypting S3 bucket"
  AppID                           = "1001"
  Environment                     = "Dev"
  DataClassification              = "Internal"
  CRIS                            = "Low"
  Notify                          = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                           = ["abc1", "def2", "ghi3"]
  Compliance                      = ["None"]
  Order                           = 8115205
  optional_tags                   = { service = "waf-v2" }
  name                            = "web-acl-cloudfront"
  wafv2_ip_set_description        = "Waf ipset testing"
  wafv2_ip_set_ip_address_version = "IPV4"
  wafv2_ip_set_addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  webacl_description              = "waf ipset"
  request_default_action          = "block"
  cloudwatch_metrics_enabled      = false
  sampled_requests_enabled        = false
  metric_name                     = "metric-name"
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
  logging_filter = {
    default_behavior = "DROP"
    filter = [
      {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        condition = [
          {
            action_condition = {
              action = "ALLOW"
            }
          },
        ]
      },
      {
        behavior    = "DROP"
        requirement = "MEETS_ALL"
        condition = [
          {
            action_condition = {
              action = "COUNT"
            }
          },
          {
            label_name_condition = {
              label_name = "awswaf:"
            }
          }
        ]
      }
    ]
  }
  aws_kinesis_firehose_delivery_stream_name = "aws-waf-logs-test-iac-tf-23"
  policy_arns                               = ["arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"]
  aws_service                               = ["firehose.amazonaws.com"]
}
