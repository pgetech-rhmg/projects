        run "rest_api_open_api_waf" {
          command = apply
                            
          module {
            source = "./examples/rest_api_open_api_waf"
          }
        }
        
        variables {
        account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
AppID       = "1001" 
Environment = "Dev"  
DataClassification = "Internal"                                       
CRIS               = "Low"                                            
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] 
Owner              = ["abc1", "def2", "ghi3"]                         
Compliance         = ["None"]
Order              = 8115205                                           
rest_api_name = "rest_api_open_api"
pVpcEndpoint = "vpce-0153835f967c30984"
stage_name                  = "open_api_stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"
api_key_name = "sample_api_key"
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"
usage_plan_key_type = "API_KEY"
key          = "sample"
content      = "abcdefg"
content_type = "TEXT_PLAIN"
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
        }
