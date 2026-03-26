account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
optional_tags      = { managed_by = "terraform" }
Order              = 8115205   #Order tag is required and must be a number between 7 and 9 digits

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet3/id"

#common name
name = "test-standard-sf-workflow"

#cloudwatch_log-group
cloudwatch_log_name_prefix = "/aws/vendedlogs/states/standard_workflow"

#standard_workflow
state_machine_definition      = "state_machine_definition.json"
tracing_configuration_enabled = true
publish                       = true

#Lambda
runtime                    = "python3.9"
handler                    = "lambda_function.lambda_handler"
local_zip_source_directory = "lambda_source_code"

#aws_lambda_iam_role
lambda_iam_role_name   = "lamba-standard-sf-role"
lambda_iam_aws_service = ["lambda.amazonaws.com"]
lambda_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]

#aws_state_machine_iam_role
state_machine_iam_role_name   = "standard-state-machine-role"
state_machine_iam_aws_service = ["states.amazonaws.com"]
state_machine_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaRole", "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]

#vpc-endpoint
private_dns_enabled = true
service_name        = "com.amazonaws.us-west-2.states"

#vpc-endpoint security group
vpce_security_group_name = "standard-workflow-vpce-sg"