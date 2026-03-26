# This example needs to use the 514 account since the FSx for Windows file system is in the 514 account and we cannot
# create an FSx for Windows file system in the 750 account.
account_num = "514712703977"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA, BCSI or None
Order              = 8115205                                          #Order must be between 7 and 9 digits

task_name = "ccoe-s3-to-fsx_windows"

# IAM role and policy template values
s3_role_name = "s3_datasync_access_role"
aws_service  = ["datasync.amazonaws.com"]
bucket_name  = "ccoe-test-datasync-bucket"

# s3 location values
s3_location_subdirectory = "my-subdirectory"

# FSx for Windows location values
fsx_location_arn = "arn:aws:fsx:us-west-2:514712703977:file-system/fs-005770afa99688362"
domain           = null
fsx_user         = "rzhk"
fsx_password     = "rzhk1"
