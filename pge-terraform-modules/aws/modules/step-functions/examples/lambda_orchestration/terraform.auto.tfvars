account_num = "750713712981"
aws_region  = "us-west-2"
kms_role    = "TF_Developers"
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
subnet_id1_name = "/vpc/privatesubnet3/id"

#lambda_orchestration
state_machine_definition = "state_machine_definition.json"

#common name
name = "lambda-orchestration-test-workflow"

#lambda_check_stock_price
lambda_check_stock_price_name      = "CheckStockPriceLambda"
lambda_check_stock_price_directory = "stock_price_directory_source_code"

#lambda_generate_buy_sell_recommendation
lambda_generate_buy_sell_recommendation_name      = "GenerateBuySellRecommend"
lambda_generate_buy_sell_recommendation_directory = "generate_buy_sell_recommendation_directory_source_code"

#lambda_approve_sqs
lambda_approve_sqs_name      = "ApproveSqsLambda"
lambda_approve_sqs_directory = "approve_sqs_directory_source_code"

#lambda_buy_stock
lambda_buy_stock_name      = "BuyStockLambda"
lambda_buy_stock_directory = "buy_stock_directory_source_code"

#lambda_sell_stock
lambda_sell_stock_name      = "SellStockLambda"
lambda_sell_stock_directory = "sell_stock_directory_source_code"

runtime = "nodejs18.x"
handler = "index.lambdaHandler"

#cloudwatch_log-group
cloudwatch_log_name_prefix = "/aws/vendedlogs/states/lambda_orchestration"

#lambda_Iam_role 
lambda_iam_role_name   = "lambda-orchestration-sf-role"
lambda_iam_aws_service = ["lambda.amazonaws.com"]

#aws_state_machine_iam_role
state_machine_iam_role_name   = "lambda-orchestration-state-machine-role"
state_machine_iam_aws_service = ["states.amazonaws.com"]

#vpc-endpoint
private_dns_enabled = true
service_name        = "com.amazonaws.us-west-2.states"

#vpc-endpoint security group
vpce_security_group_name = "lambda-orchestration-workflow-vpce-sg"