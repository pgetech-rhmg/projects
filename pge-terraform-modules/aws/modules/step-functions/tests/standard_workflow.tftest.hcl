run "standard_workflow" {
  command = apply

  module {
    source = "./examples/standard_workflow"
  }
}

variables {
  account_num                   = "750713712981"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  kms_role                      = "CloudAdmin"
  kms_name                      = "ccoe-kms-step-function-example"
  kms_description               = "A test key created for the step-function TF module"
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
  subnet_id1_name               = "/vpc/2/privatesubnet3/id"
  name                          = "test-standard-sf-workflow"
  cloudwatch_log_name_prefix    = "/aws/vendedlogs/states/standard_workflow"
  state_machine_definition      = "state_machine_definition.json"
  tracing_configuration_enabled = true
  publish                       = true
  runtime                       = "python3.9"
  handler                       = "lambda_function.lambda_handler"
  local_zip_source_directory    = "lambda_source_code"
  lambda_iam_role_name          = "lamba-standard-sf-role"
  lambda_iam_aws_service        = ["lambda.amazonaws.com"]
  lambda_iam_policy_arns        = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  state_machine_iam_role_name   = "standard-state-machine-role"
  state_machine_iam_aws_service = ["states.amazonaws.com"]
  state_machine_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaRole", "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
  private_dns_enabled           = true
  service_name                  = "com.amazonaws.us-west-2.states"
  vpce_security_group_name      = "standard-workflow-vpce-sg"
}
