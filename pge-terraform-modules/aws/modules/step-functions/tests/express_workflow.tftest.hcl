run "express_workflow" {
  command = apply

  module {
    source = "./examples/express_workflow"
  }
}

variables {
  account_num                   = "750713712981"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  AppID                         = "1001"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                         = ["abc1", "def2", "ghi3"]
  Compliance                    = ["None"]
  optional_tags                 = { managed_by = "terraform" }
  Order                         = 8115205
  vpc_id_name                   = "/vpc/id"
  subnet_id1_name               = "/vpc/privatesubnet3/id"
  name                          = "test-express-sf-workflow"
  state_machine_definition      = "state_machine_definition.json"
  tracing_configuration_enabled = true
  state_machine_type            = "EXPRESS"
  cloudwatch_log_name_prefix    = "/aws/vendedlogs/states/express_workflow"
  runtime                       = "python3.9"
  handler                       = "lambda_function.lambda_handler"
  local_zip_source_directory    = "lambda_source_code"
  lambda_iam_role_name          = "lamba-express-sf-role"
  lambda_iam_aws_service        = ["lambda.amazonaws.com"]
  lambda_iam_policy_arns        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  state_machine_iam_role_name   = "express-state-machine-role"
  state_machine_iam_aws_service = ["states.amazonaws.com"]
  state_machine_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaRole", "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
  private_dns_enabled           = true
  service_name                  = "com.amazonaws.us-west-2.states"
  vpce_security_group_name      = "express-workflow-vpce-sg"
}
