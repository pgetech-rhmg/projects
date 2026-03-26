account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


#tag variables
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one environment) 
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"      # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205                                          #Order must be between 7 and 9 digits

#secretmanager variables
secretsmanager_name        = "test-sm-custom-policy"
secretsmanager_description = "testing of the secrets manager for custom policy"
recovery_window_in_days    = 0 # this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
policy_file_name           = "test_policy.json"

#kms variables
kms_name        = "sm-cmk-custom"
kms_description = "CMK for encrypting secretsmanager for custom policy"