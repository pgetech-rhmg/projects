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
Owner              = ["abc1", "def2", "ghi3"]                         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                                         #Identify assets with compliance requirements SOX, HIPAA, CCPA, BCSI or None
Order              = 8115205                                          #Order must be between 7 and 9 digits

task_name = "ccoe-s3-to-s3"

# IAM role and policy template values
s3_role_name            = "s3_datasync_access_role"
aws_service             = ["datasync.amazonaws.com"]
source_bucket_name      = "ccoe-test-datasync-source"
destination_bucket_name = "ccoe-test-datasync-destination"

# s3 location values
source_location_subdirectory      = "my-subdirectory"
destination_location_subdirectory = "my-subdirectory"

# options block values
# Since this is s3 based, we need to set all posix related permissions to NONE
posix_permissions = "NONE"
gid               = "NONE"
uid               = "NONE"