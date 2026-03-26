aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order tag is required and must be a number between 7 and 9 digits
optional_tags      = { service = "waf-v2" }

wafv2_ip_set_description        = "Waf ipset testing"
wafv2_ip_set_ip_address_version = "IPV4"
wafv2_ip_set_addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

# Common name
name = "web-acl-regional-alb"

webacl_description     = "waf ipset"
request_default_action = "block"

cloudwatch_metrics_enabled = false
sampled_requests_enabled   = false
metric_name                = "metric-name"

# SSM Parameter store variables

vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
subnet_id2_name = "/vpc/2/privatesubnet3/id"

# Example managed rules configuration
# Note: The first rule (AWSManagedRulesCommonRuleSet) will automatically use the created IPSet
# This demonstrates the new IPSet attachment capability
managed_rules = [
  {
    name            = "AWSManagedRulesCommonRuleSet",
    priority        = 10
    override_action = "none"
    excluded_rules  = []
    # This rule will be overridden in main.tf to use the created IPSet
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

# geo_match_statement_rule

geo_match_statement_rules = [
  {
    name     = "geo_match1"
    priority = 3
    action   = "block"
    custom_response = {
      custom_response_body_key = "sample"
      response_code            = 403
      response_header = [{
        name  = "sample"
        value = "test"
      }]
    }
    statement = {
      country_codes = ["US", "NL"]
      forwarded_ip_config = {
        fallback_behavior = "MATCH"
        header_name       = "header3"
      }
    }
    rule_label = [{
      name = "label5"
    }]
    visibility_config = [{
      metric_name = "metric1"
    }]
}]

# label_match_statement_rule

label_match_statement_rules = [
  {
    name     = "label_match1"
    priority = 9
    action   = "block"
    custom_response = {
      custom_response_body_key = "sample"
      response_code            = 403
      response_header = [{
        name  = "sample"
        value = "test"
      }]
    }
    statement = {
      scope = "LABEL"
      key   = "key"
    }
    rule_label = [{
      name = "label4"
    }]
    visibility_config = [{
      metric_name = "metric1"
    }]
}]

# byte_match_statement_rule

byte_match_rule = [
  {
    name     = "byte-match"
    action   = "allow"
    priority = 14

    statement = {
      positional_constraint = "EXACTLY"
      search_string         = "test"
      field_to_match = {
        headers = {
          match_pattern = [{
            included_headers = ["KeyToInclude1", "KeyToInclude2", "KeyToInclude3"]
          }]
          match_scope       = "ALL"
          oversize_handling = "CONTINUE"
        }
      }
      text_transformation = [
        {
          priority = 15
          type     = "COMPRESS_WHITE_SPACE"
        }
      ]
    }

    rule_label = [{
      name = "bytelabel"
    }]
    visibility_config = [{
      metric_name = "metric1"
    }]

}]

# xss_match_statement_rule

xss_match_rule = [
  {
    name     = "xss-match"
    action   = "allow"
    priority = 16

    statement = {
      field_to_match = {
        cookies = {
          match_pattern = [{
            included_cookies = ["KeyToInclude1", "KeyToInclude2", "KeyToInclude3"]
          }]
          match_scope       = "KEY"
          oversize_handling = "MATCH"
        }
      }
      text_transformation = [
        {
          priority = 15
          type     = "COMPRESS_WHITE_SPACE"
        }
      ]
    }

    rule_label = [{
      name = "xsslabel"
    }]
    visibility_config = [{
      metric_name = "metric1"
    }]

}]

# Values for aws_wafv2_web_acl_association
enable_webacl_resource_association = true

# Values for aws_wafv2_web_acl_logging
aws_kinesis_firehose_delivery_stream_name = "aws-waf-logs-test-iac-tf-23"

# Values for iam role
policy_arns = ["arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"]
aws_service = ["firehose.amazonaws.com"]

# Values for security_group alb
alb_sg_description = "Security group for example usage with waf_v2_regional_loadbalancer"
cidr_ingress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.232.0/25", "10.90.232.128/25"]
  ipv6_cidr_blocks = []
  description      = "CCOE Ingress rules"
  prefix_list_ids  = []
}]
cidr_egress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.232.0/25", "10.90.232.128/25"]
  ipv6_cidr_blocks = []
  description      = "CCOE egress rules"
  prefix_list_ids  = []
}]