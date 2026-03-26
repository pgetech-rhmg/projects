account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

kms_role        = "CloudAdmin"
kms_name        = "ccoe-kms-appconfig-example"
kms_description = "A test key created for the AppConfig TF module"

# Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205                                           #Order must be a 7-digit number

# Configuration profile
application_id = "3jcwgsa"
name           = "ccoe-config-profile-1"
