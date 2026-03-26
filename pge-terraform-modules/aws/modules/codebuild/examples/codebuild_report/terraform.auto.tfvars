account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#Tags
AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None

#kms_key
kms_name        = "codebuild_report_cmk"
kms_description = "cmk for codebuild report"

#S3-bucket
bucket_name = "codebuild-report-test-bucket"

#codebuild_report_group
codebuild_rg_name           = "test-report"
codebuild_rg_type           = "TEST"
codebuild_rg_delete_reports = true
codebuild_rg_export_type    = "S3"
codebuild_rg_packaging      = "NONE"
codebuild_rg_path           = "/home"
policy_file_name            = "policy.json"