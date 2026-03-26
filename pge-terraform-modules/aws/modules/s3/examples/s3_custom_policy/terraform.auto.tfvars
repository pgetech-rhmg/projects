aws_region      = "us-west-2"
kms_role        = "CloudAdmin"
account_num     = "750713712981"
aws_role        = "CloudAdmin"
bucket_name     = "ccoe-s3-custom-bucket-test-pge"
kms_name        = "s3_bucket_kms_01"
kms_description = "ccoe-s3-bucket-kms"
#versioning = "Enabled"  # use this incase if enabling is required for s3 bucket versioning
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification       = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS                     = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner                    = ["abc1", "def2", "ghi3"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance               = ["None"]                 #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order                    = 8115205                  #Order must be between 7 and 9 digits
intelligent_tiering_name = "ccoe-intelligent-tiering-test-pge"
deeparchive_days         = 180 # Number of days after object creation when it transitions to the DEEP_ARCHIVE_ACCESS tier. Must be a positive integer.
archive_days             = 90  # Number of days after object creation when it transitions to the ARCHIVE_ACCESS tier. Must be a positive integer.    