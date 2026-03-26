account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"



AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits"

ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/privatesubnet2/id"



### KMS ###
kms_key         = "pge-ssm-kms-rb1c"
kms_description = "The description of the key as viewed in AWS console."



### sns_iam_role ###
sns_iam_name        = "sns_ssm_patch_mgr_role_example"
sns_iam_aws_service = ["ssm.amazonaws.com"]

# sns_notification_enabled = true
snstopic_name         = "sns_ssm_mw_ccoe_test"     # Name of the SNS topic
snstopic_display_name = "sns_ssm_mw_ccoe_examples" # Display name of the SNS topic

endpoint = ["sycz@pge.com"] #Endpoint to send data to. The contents vary with the protocol. 
protocol = "email"          #Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported.


##############################
# Creating SSM-Document in JSON
##############################

ssm_document_name   = "ccoe_patch_document_example1"
ssm_document_type   = "Automation" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "JSON"       ## Valid document types include: JSON and YAML


############################################################
# Creating Lambda funtion for SSM state manager association
############################################################

document_iam_name        = "ccoe_remidiation_automation_doc_iam_role_example"
document_iam_aws_service = ["ssm.amazonaws.com"]

#Lamabda
lambda_function_name = "baseline-overrides"
lambda_iam_name      = "ccoe-BaselineOverride-LambdaRole-example"


# SSM Association
ssm_association_name   = "ssm_association_test"
schedule_expression    = "cron(0 0/12 * * ? *)"
statemanager_s3_bucket = "statemanger-output-s3-bkt-test"

### S3 ###
document_bucket_name = "aws-quicksetup-patch-test"
output_s3_key_prefix = "logs/AutomationDocument"


cidr_egress_rules_codebuild = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]




##############################
# Creating Patch Baseline
##############################

ssm_patch_baseline_name           = "PGE-AmazonLinux2PatchBaseline-test"
operating_system                  = "AMAZON_LINUX_2" ## Valid values are WINDOWS, AMAZON_LINUX, AMAZON_LINUX_2, SUSE, UBUNTU, CENTOS, and REDHAT_ENTERPRISE_LINUX
set_default_patch_baseline        = false            ## Set it true, if you want to make this a default baseline. Default value is false.
approved_patches_compliance_level = "HIGH"           ## Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED.

patch_baseline_approval_rules = [
  {
    approve_after_days  = 1
    compliance_level    = "HIGH"
    enable_non_security = true
    patch_baseline_filters = [
      {
        name   = "PRODUCT"
        values = ["AmazonLinux2", "AmazonLinux2.0"]
      },
      {
        name   = "CLASSIFICATION"
        values = ["Security", "Bugfix", "Recommended"]
      },
      {
        name   = "SEVERITY"
        values = ["Critical", "Important"]
      }
    ]
  },
  {
    approve_after_days  = 7
    compliance_level    = "MEDIUM"
    enable_non_security = false
    patch_baseline_filters = [
      {
        name   = "PRODUCT"
        values = ["AmazonLinux2", "AmazonLinux2.0"]
      },
      {
        name   = "CLASSIFICATION"
        values = ["Newpackage"]
      },
      {
        name   = "SEVERITY"
        values = ["Important"]
      }
    ]
  }
]

####################################################
#### Patch Groups #####

patch_group_names = ["test1"]
aws_org_id        = "o-3dot1zcpsr"

#max_concurrency ="10%"
apply_only_at_cron_interval = true