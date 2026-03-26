run "lambda_function_inline" {
  command = apply

  module {
    source = "./examples/lambda_function_inline"
  }
}

variables {
  account_num                    = "750713712981"
  aws_region                     = "us-west-2"
  aws_role                       = "CloudAdmin"
  vpc_id_name                    = "/vpc/id"
  subnet_id1_name                = "/vpc/2/privatesubnet1/id"
  subnet_id2_name                = "/vpc/2/privatesubnet2/id"
  subnet_id3_name                = "/vpc/2/privatesubnet3/id"
  AppID                          = "1001"
  Environment                    = "Dev"
  DataClassification             = "Internal"
  CRIS                           = "Low"
  Notify                         = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                          = ["abc1", "def2", "ghi3"]
  Compliance                     = ["None"]
  Order                          = 8115205
  name                           = "lambda-inline-code-test"
  description                    = "testing aws lambda with inline code"
  runtime                        = "python3.9"
  handler                        = "index.hello_world"
  content                        = <<EOF
def hello_world(event_data, lambda_config):
    print ("hello world")
EOF
  filename                       = "index.py"
  reserved_concurrent_executions = 5
  iam_aws_service                = ["lambda.amazonaws.com"]
  iam_policy_arns                = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  optional_tags = {
    Name = "test_lambda"
  }
}
