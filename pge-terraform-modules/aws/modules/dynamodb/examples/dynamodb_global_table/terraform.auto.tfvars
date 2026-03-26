aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

# Tag variables

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                          #Order must be between 7 and 9 digits

# dynamodb table variables

table_name = "test-dynamodb-123-oxdi"
hash_key   = "UserId"
hash_range_key_attributes = [
  {
    name = "UserId"
    type = "S"
  }
]
create_replica   = false #To create global table replica set this to true
stream_enabled   = true
stream_view_type = "NEW_AND_OLD_IMAGES"

#kms_key
kms_name        = "kms-dynamodb-123"
kms_description = "CMK for encrypting dynamodb global table"

