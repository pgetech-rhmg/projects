account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
subnet_id2_name = "/vpc/2/privatesubnet2/id"
subnet_id3_name = "/vpc/2/privatesubnet3/id"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits"

#Lambda
name        = "lambda-inline-code-test"
description = "testing aws lambda with inline code"
runtime     = "python3.13"
handler     = "index.hello_world"
content     = <<EOF
def hello_world(event_data, lambda_config):
    print ("hello world")
EOF
filename    = "index.py"
reserved_concurrent_executions = 5
logging_config = {
  application_log_level = "INFO"
  log_format = "JSON"
  system_log_level = "INFO"
}


#Iam_role 
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]

optional_tags = {
  Name = "test_lambda"
}