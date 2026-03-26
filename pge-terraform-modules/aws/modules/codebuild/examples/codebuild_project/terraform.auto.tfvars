account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#kms_key
kms_name        = "codebuild_key"
kms_description = "kms key for codebuild"
#Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order tag is required and must be a number between 7 and 9 digits

codebuild_project_name        = "codebuild_project_test_ccoe-6902"
codebuild_project_description = "sample codebuild_project"
concurrent_build_limit        = 1
artifact_type                 = "NO_ARTIFACTS"
cache_type                    = "S3"
compute_type                  = "BUILD_GENERAL1_SMALL"
environment_image             = "aws/codebuild/standard:1.0"
environment_type              = "LINUX_CONTAINER"
image_pull_credentials_type   = "CODEBUILD"

cloudwatch_logs_group_name  = "logs-group"
cloudwatch_logs_stream_name = "logs-stream"
s3_logs_status              = "ENABLED"

source_git_clone_depth = 1
source_type            = "GITHUB_ENTERPRISE"
source_location        = "https://github.com/pgetech/test-codebuild-repo"
source_fetch_sub       = true


#codebuild_project_policy
policy_file_name = "policy.json"

#security_group
sg_name        = "sg_cb_project_aicg"
sg_description = "security group for codebuild project"
cidr_egress_rules = [{
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

## AWS Secrets Manager - GitHub Token
# For testing this example, you need to create a GitHub token and store it in AWS Secrets Manager.
# Provide the **ARN** of the secret in the variable "secretsmanager_github_token_secret_arn".

# Note: Previously, this variable used the secret name. It has now been updated to use the full ARN.

secretsmanager_github_token_secret_arn = "arn:aws:secretsmanager:us-west-2:750713712981:secret:github_token_stco-JMu81a"

# Steps to create the secret in AWS Secrets Manager:
# 1. Create a plain text secret with the following key-value pairs:
#    - ServerType = GITHUB
#    - AuthType = PERSONAL_ACCESS_TOKEN
#    - Token = "your_personal_access_token"                                   


#kms_key
# kms_name        = "codebuild_key"
# kms_description = "kms key for codebuild"

#iam_role
role_name    = "cbproject_iam_role_aicg"
role_service = ["codebuild.amazonaws.com"]


#S3-bucket
bucket_name = "mybucket143mmtest"

#github_webhook
github_repository   = "test-codebuild-repo"
github_events       = ["push"]
github_content_type = "json"
github_base_url     = "https://api.github.com/"