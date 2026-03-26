account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#tag variables
AppID              = "1001"     #Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"      #Dev, Test, QA, Prod (only one environment) 
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]

#secretsmanager variables
secretsmanager_name        = "test-sm-rotation-l"
secretsmanager_description = "testing secrets manager with rotation enabled "
kms_name                   = "sm-cmk-rotation"
kms_description            = "CMK for encrypting secretsmanager with rotation enabled"
secret_string              = "demo"
secret_version_enabled     = true
rotation_enabled           = true
rotation_after_days        = 1
recovery_window_in_days    = 0 #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
policy_file_name           = "custom_policy_sm.json"

#lambda variables
lambda_function_name  = "secretsmanagerlambda1"
lambda_description    = "Lambda function code for secretsmanager rotation"
lambda_handler_name   = "index.lambda_handler"
lambda_runtime        = "python3.9"
source_dir            = "lambda_source_code"
timeout               = 300
publish               = true
environment_variables = { SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.us-west-2.amazonaws.com" }
action                = "lambda:InvokeFunction"
principal             = "secretsmanager.amazonaws.com"

#security group variable
sg_name_lambda = "test-lambda"
cidr_ingress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
}]
cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

#kms
template_file_name = "custom_policy_kms.json"

#aws_lambda_iam_role
role_name    = "lambsa_sm_role"
role_service = ["lambda.amazonaws.com"]

vpc_id_name    = "/vpc/2/id"
subnet_id_name = "/vpc/2/privatesubnet1/id"

