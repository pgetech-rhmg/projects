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

##### aws_cloudfront_origin_access_identity###
comment_cf_oai = "cloudfront-origin-access-identity"

comment_cfd         = "Cloudfront-distribution"
default_root_object = "index.html"
enabled             = true
http_version        = "http2"

df_cache_behavior_allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
df_cache_behavior_cached_methods         = ["GET", "HEAD"]
df_cache_behavior_viewer_protocol_policy = "redirect-to-https"

geo_restriction = [{
  restriction_type = "whitelist",
  locations        = ["US", "CA"]
}]

custom_error_response = [
  {
    error_caching_min_ttl = 1
    error_code            = 404
    response_code         = 200
    response_page_path    = "/"
  }
]

forwarded_values = [{
  query_string = false
  cookies = [{
    forward = "none"
  }]
}]

lambda_event_type = "origin-request"

custom_header_name  = "s3-region"
custom_header_value = "us-east-1" # region where the s3 bucket is created

origin_shield_enabled = false
origin_shield_region  = "us-west-2"


##########################################################################

#Kms
kms_name               = "lambda-test-cmk-key"
kms_description        = "CMK for encrypting lambda"
kms_template_file_name = "kms_user_policy.json"

##########################################################################

bucket_name = "s3-static-lambda-edge"

custom_domain_name = "lambda-edge-pge.nonprod.pge.com"

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
  allowed_origins = ["https://lambda-edge-pge.nonprod.pge.com"]
  expose_headers  = ["ETag"]
  max_age_seconds = 3000
  id              = null
}]

##########################################################################


#Lambda@edge
function_name              = "lambda-local-cloudfront-resource"
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


