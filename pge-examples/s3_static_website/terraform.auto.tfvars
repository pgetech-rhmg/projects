aws_region         = "us-west-2"
account_num        = "750713712981"
aws_role           = "CloudAdmin"
kms_role           = "CloudAdmin"
custom_bucket_name = "ccoe-statics3-bucket-test"
website = {
  index_document = "index.html"
  error_document = "error.html"
  routing_rules = [{
    condition = {
      key_prefix_equals = "docs/"
    },
    redirect = {
      replace_key_prefix_with = "documents/"
    }
    }, {
    condition = {
      http_error_code_returned_equals = 404
      key_prefix_equals               = "archive/"
    },
    redirect = {
      host_name          = "archive.myhost.com"
      http_redirect_code = 301
      protocol           = "https"
      replace_key_with   = "not_found.html"
    }
  }]
}

kms_name        = "s3_static_bucket_kms"
kms_description = "ccoe-s3-static-bucket-kms"

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