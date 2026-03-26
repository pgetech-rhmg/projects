account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

#parameter store names
vpc_id_name     = "/vpc/2/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"

#Tags
AppID              = "443"                                            #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["m7k3@pge.com", "c1gx@pge.com", "sy10@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["m7k3", "c1gx", "sy10"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                          #Order must be between 7 and 9 digits

#secretsmanager variables
secretsmanager_name        = "git-credentials-test"
secretsmanager_description = "git pat"
#plaintext_secret           = "<git_pat_value>" #example for plaintext, enter sensitive values directly on workspace, do not commit to github
#key_value_secret = {git_pat:"<token>"}  #example for key/value pair, enter sensitive values directly on workspace, do not commit to github. To run with terraform test make sure to add local env variable by running `export TF_VAR_key_value_secret='{git_pat:"<token>"}'
store_as_key_value      = true #change to false if you are storing secret value as plaintext secret
secret_version_enabled  = true
recovery_window_in_days = 0 #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.

#Kms
kms_name        = "git-token-renewal-notification"
kms_description = "CMK for encrypting git token renewal notification lambda function and secrets manager credentials"

#Lambda
function_name  = "git-token-renewal-notification"
description    = "git token renewal remainder notification lambda function"
runtime        = "python3.12"
handler        = "lambda_function.lambda_handler"
source_dir     = "lambda_source_code"
lambda_timeout = 300
publish        = true

#security_group
lambda_sg_name        = "git-token-renewal-lambda-sg"
lambda_sg_description = "Security group for git token renewal notification lambda"

# lambda_cidr_ingress_rules = [{
#     from             = 443,
#     to               = 443,
#     protocol         = "tcp",
#     cidr_blocks      = ["172.30.0.0/16", "192.168.0.0/16", "10.0.0.0/8"]
#     ipv6_cidr_blocks = []
#     description      = "CCOE Ingress rules"
# }]

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
iam_name        = "git-token-renewal-notification-role"
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite", "arn:aws:iam::aws:policy/AmazonSNSFullAccess"]

#cloudwatch_event_rule_name

cloudwatch_event_rule_name        = "git-token-renewal-notification"
cloudwatch_event_rule_description = "event to trigger with cron expression to notify renewwal of git token"
cron_schedule_expression          = "rate(2 days)"

#sns

snstopic_name         = "git-token-renewal-notification"           # Name of the SNS topic
snstopic_display_name = "git-token-renewal-notification sns topic" # Display name of the SNS topic

endpoint = ["m7k3@pge.com"] #Endpoint to send data to. The contents vary with the protocol.
protocol = "email"
