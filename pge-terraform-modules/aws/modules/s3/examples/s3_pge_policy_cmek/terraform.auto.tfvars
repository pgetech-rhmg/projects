aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


kms_name        = "s3_cmek_bucket_kms_01"
kms_description = "ccoe-s3-cmek-bucket-kms"



grants = [
  {
    id          = null
    type        = "Group"
    permissions = ["READ"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  },
  {
    id          = null
    type        = "Group"
    permissions = ["WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  },
]


object_lock_configuration = {
  mode  = "GOVERNANCE"
  days  = 366
  years = null
}

versioning = "Enabled"

cors_rule_inputs = [{
  allowed_headers = ["*"]
  allowed_methods = ["PUT", "POST"]
  allowed_origins = ["https://s3-website-test.hashicorp.com"]
  expose_headers  = ["ETag"]
  max_age_seconds = 3000
  id              = null
}]

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                 #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                  #Order must be between 7 and 9 digits