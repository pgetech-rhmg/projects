name                = "FIS-Testing-EC2-terminate-CloudWatch-logging"
fis_experiment_name = "FIS-Testing-EC2-terminate-CloudWatch-logging"
account_num         = "750713712981"
aws_service         = ["fis.amazonaws.com"]
aws_region          = "us-west-2"
aws_role            = "CloudAdmin"

# Required variables for example infrastructure
fis_role_name = "" # Empty = create new role, or specify existing role name
inline_policy = [
  # Example: Basic additional permissions (the root module already provides comprehensive FIS policies)
  # Uncomment below to add additional permissions:
  # <<-EOF
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Effect": "Allow",
  #       "Action": [
  #         "logs:CreateLogStream"
  #       ],
  #       "Resource": "*"
  #     }
  #   ]
  # }
  # EOF
]
policy_name        = "fis_managed_policy_cloudwatch_dev"
policy_description = "IAM policy for FIS experiment with CloudWatch logging"
policy_content     = "" # Empty = use default policy, or provide custom JSON policy
LogGroupNamePrefix = "/aws/fis/"

# PGE Required Tags
AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          # Order tag is required and must be a number between 7 and 9 digits

# Optional Tags
optional_tags = {
  Purpose = "chaos-engineering-cloudwatch-logging"
}

# General Configuration
description = "Terminate EC2 instances experiment with CloudWatch logging"

# Experiment Options
experiment_options = {
  account_targeting            = "single-account"
  empty_target_resolution_mode = "fail"
}

# Stop Conditions
stop_condition = [
  {
    source = "none"
    value  = ""
  }
]

# Targets - Option 1: Use existing tags (like Name)
target = [
  {
    name           = "SpecificInstances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "COUNT(1)" # Start with just 1 instance for testing
    resource_arns  = []
    filter         = []
    resource_tags = [
      {
        key   = "Fis"
        value = "Chaos"
      },
      {
        key   = "Environment"
        value = "Dev"
      }
    ]
  }
]

# Alternative: Use specific instance ARNs if you know them
# target = [
#   {
#     name           = "SpecificInstances"
#     resource_type  = "aws:ec2:instance"
#     selection_mode = "ALL"
#     resource_arns  = [
#       "arn:aws:ec2:us-west-2:750713712981:instance/i-1234567890abcdef0"
#     ]
#     filter         = []
#     resource_tags  = []
#   }
# ]

# Actions
action = [
  {
    name        = "StopInstances"
    action_id   = "aws:ec2:stop-instances"
    description = "Stops specific EC2 instances for resilience testing"
    start_after = []
    parameter   = {}
    target = [
      {
        key   = "Instances"
        value = "SpecificInstances"
      }
    ]
  }
]

# CloudWatch Logging Configuration
log_type                  = "cloudwatch"
log_schema_version        = 1
cloudwatch_log_group_name = "my-cloudwatch-log-group"

# S3 Configuration (required even for CloudWatch logging)
s3_bucket_name = ""
s3_logging = {
  prefix = ""
}