account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"

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

#Kms
kms_name        = "lambda-test-cmk-key"
kms_description = "CMK for encrypting lambda"

#Lambda
function_name         = "lambda-local-tf-test"
description           = "testing aws lambda"
runtime               = "python3.9"
handler               = "lambda_function.lambda_handler"
environment_variables = { name = "aqaflambda" }
source_dir            = "lambda_source_code"

#lambda_layer
layer_version_layer_name                 = "lambda-test-layer"
layer_version_compatible_architectures   = "x86_64"
layer_version_compatible_runtimes        = ["python3.9"]
layer_version_local_zip_source_directory = "lambda_layer_source_code"

#layer_permission
layer_version_permission_action       = "lambda:GetLayerVersion"
layer_version_permission_statement_id = "dev-account"
layer_version_permission_principal    = "*"

#lambda_alias
lambda_alias_name        = "lambda-test-alias"
lambda_alias_description = "Creates a Lambda function alias"

#lambda_event_source_mapping_kinesis
starting_position = "LATEST"

#security_group
lambda_sg_name        = "lambda_sg"
lambda_sg_description = "Security group for example usage with lambda"

lambda_cidr_ingress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
}]

lambda_cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

#Iam_role 
iam_name        = "lambda_policy"
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonKinesisFullAccess", "arn:aws:iam::aws:policy/AmazonSQSFullAccess"]
