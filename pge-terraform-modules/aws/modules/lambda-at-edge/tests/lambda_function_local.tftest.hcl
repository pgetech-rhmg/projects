run "lambda_function_local" {
  command = apply

  module {
    source = "./examples/lambda_function_local"
  }
}

variables {
  aws_region                 = "us-west-2"
  account_num                = "750713712981"
  aws_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  function_name              = "lambda-edge-local-provider-test"
  description                = "testing aws lambda edge"
  runtime                    = "python3.9"
  handler                    = "lambda_function.lambda_handler"
  local_zip_source_directory = "lambda_source_code"
  lambda_alias_name          = "live"
  lambda_alias_description   = "Creates a Lambda function alias"
  iam_name                   = "lambda-edge-policy"
  policy_arns_list           = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  policy_name                = "ccoe_terraform_multiple_policies"
  policy_path                = "/"
  policy_description         = "policy creation for ccoe terrform test"
  Order                      = 8115205
  optional_tags = {
    Name = "test_lambda"
  }
}
