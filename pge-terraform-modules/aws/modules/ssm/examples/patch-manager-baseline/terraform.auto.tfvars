account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID              = "1001"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"      #Dev, Test, QA, Prod (only one)
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits"


##############################
# Creating Patch Baseline
##############################

ssm_patch_baseline_name           = "ssm_patch_baseline_aicg"
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

patch_group_names = ["Dev"]