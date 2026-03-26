aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

kms_name        = "lanid-waf-v2-s3-bucket"
kms_description = "CMK for encrypting S3 bucket"

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

# Common variable name for resources
name = "web-acl-cloudfront"

wafv2_ip_set_description        = "Waf ipset testing"
wafv2_ip_set_ip_address_version = "IPV4"
wafv2_ip_set_addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

webacl_description     = "waf ipset"
request_default_action = "block"

cloudwatch_metrics_enabled = false
sampled_requests_enabled   = false
metric_name                = "metric-name"

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

# Values for aws_wafv2_web_acl_logging
aws_kinesis_firehose_delivery_stream_name = "aws-waf-logs-test-iac-tf-23"

# Values for iam role
policy_arns = ["arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"]
aws_service = ["firehose.amazonaws.com"]