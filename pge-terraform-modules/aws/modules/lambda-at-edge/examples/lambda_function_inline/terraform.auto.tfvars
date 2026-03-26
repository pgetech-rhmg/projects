aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

#Tags
AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None

#Lambda
function_name = "lambda-edge-local-inline-test"
description   = "testing aws lambda edge"

file_name = "index.js" # file name with extension

runtime = "nodejs16.x"
handler = "index.handler" #file_name.function_name

lambda_alias_name        = "live"
lambda_alias_description = "Creates a Lambda function alias"


#Iam_role 
iam_name         = "lambda-edge-policy"
policy_arns_list = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess"]

policy_name        = "ccoe_terraform_multiple_policies"
policy_path        = "/"
policy_description = "policy creation for ccoe terrform test"

optional_tags = {
  Name = "test_lambda"
}