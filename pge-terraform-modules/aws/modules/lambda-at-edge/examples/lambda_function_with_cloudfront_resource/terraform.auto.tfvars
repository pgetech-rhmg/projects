account_num = "750713712981"
aws_region  = "us-east-1"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

aws_r53_role    = "CloudAdmin"
aws_r53_region  = "us-east-1"
account_num_r53 = "514712703977"

# Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI 
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None


##########################################################################

geo_restriction = [{
  restriction_type = "whitelist",
  locations        = ["US", "CA"]
}]

#Kms
kms_name               = "lambda-test-cmk-key"
kms_description        = "CMK for encrypting lambda"
kms_template_file_name = "kms_user_policy.json"

bucket_name = "s3-static-ccoe-6521"

custom_domain_name = "static-web-lambda-edge.nonprod.pge.com"

static_content = "static_content/index.html"

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

object_lock_configuration = null

cors_rule_inputs = [{
  allowed_headers = ["*"]
  allowed_methods = ["PUT", "POST"]
  allowed_origins = ["https://static-web-lambda-edge.nonprod.pge.com"]
  expose_headers  = ["ETag"]
  max_age_seconds = 3000
  id              = null
}]

##########################################################################


#Lambda
function_name              = "lambda-edge-local-cloudfront-resource"
description                = "testing aws lambda edge"
runtime                    = "nodejs18.x"
handler                    = "index.handler"
local_zip_source_directory = "lambda_source_code"

# lambda_alias_name          = "live"
# lambda_alias_description   = "Lambda@edge function test alias"


#Iam_role 
iam_name         = "lambda-edge-policy"
policy_arns_list = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

lambda_policy_name        = "ccoe_terraform_multiple_policies"
lambda_policy_path        = "/"
lambda_policy_description = "policy creation for ccoe terrform test"

optional_tags = {
  Name = "test_lambda"
}


