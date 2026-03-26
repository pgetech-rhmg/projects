lambda_name                          = "lambda-mrad"    
aws_region                           = "us-west-2"
service                              = ["lambda.amazonaws.com"]
kms_role                             = "MRAD_Ops"
archive_path                         = "."
aws_role                             = "MRAD_Ops"
aws_account                          = "Dev"
account_num                          = "990878119577"
TFC_CONFIGURATION_VERSION_GIT_BRANCH = "tfc-lambda"
optional_tags = {
  POC = ""
}