account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits
#paramter_names
#ssm_parameter_vpc_id     = "/vpc/id"
#ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"

#variable for module api_gateway_rest_api
rest_api_name = "rest_api_open_api"

#rest_api policy
# pVpcEndpoint = "vpce-0a8e888a588d032de" # internal SharedServicesV2Prod VPC Endpoint (without going through F5)
pVpcEndpoint = "vpce-0153835f967c30984"

#variable for module api_gateway_deployment_and_stage
stage_name                  = "open_api_stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5

#aws_api_gateway_method_settings
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"

#aws_api_gateway_api_key
api_key_name = "sample_api_key"

#aws_api_gateway_usage_plan
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"

#aws_api_gateway_usage_plan_key
usage_plan_key_type = "API_KEY"

key          = "sample"
content      = "abcdefg"
content_type = "TEXT_PLAIN"


############# Added for waf-v2 #########

# Common name
web_acl_name = "web-acl-regional-alb-stco"

webacl_description     = "waf ipset"
request_default_action = "block"

cloudwatch_metrics_enabled = false
sampled_requests_enabled   = false
metric_name                = "metric-name"
enable_waf                 = "true"
log_destination_arn        = "arn:aws:firehose:us-west-2:750713712981:deliverystream/aws-waf-logs-750713712981-us-west-2"

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
