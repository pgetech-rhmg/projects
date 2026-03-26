account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#parameter store names

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

#Lambda
function_name = "lambda-edge-s3-e6bo"
description   = "testing aws lambda@edge"
runtime       = "python3.9"
handler       = "lambda_function.lambda_handler"

#Kms
kms_name        = "lambda-test-cmk-key"
kms_description = "CMK for encrypting lambda"

#aws_s3_bucket
s3_bucket_name = "lambdatestbucketexample-e6bo"

#aws_s3_bucket_object
bucket_object_key    = "deployment_artifact.zip"
bucket_object_source = "lambda_function.zip"


#Iam_role 
iam_name         = "lambda_policy"
policy_arns_list = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess"]

policy_name        = "ccoe_terraform_multiple_policies"
policy_path        = "/"
policy_description = "policy creation for ccoe terrform test"