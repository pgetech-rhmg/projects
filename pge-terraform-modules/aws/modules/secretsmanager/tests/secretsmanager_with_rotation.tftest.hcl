run "secretsmanager_with_rotation" {
  command = apply

  module {
    source = "./examples/secretsmanager_with_rotation"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  kms_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  secretsmanager_name        = "test-sm-rotation-l"
  secretsmanager_description = "testing secrets manager with rotation enabled "
  kms_name                   = "sm-cmk-rotation"
  kms_description            = "CMK for encrypting secretsmanager with rotation enabled"
  secret_string              = "demo"
  secret_version_enabled     = true
  rotation_enabled           = true
  rotation_after_days        = 1
  recovery_window_in_days    = 0
  policy_file_name           = "custom_policy_sm.json"
  lambda_function_name       = "secretsmanagerlambda1"
  lambda_description         = "Lambda function code for secretsmanager rotation"
  lambda_handler_name        = "index.lambda_handler"
  lambda_runtime             = "python3.9"
  source_dir                 = "lambda_source_code"
  timeout                    = 300
  publish                    = true
  environment_variables      = { SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.us-west-2.amazonaws.com" }
  action                     = "lambda:InvokeFunction"
  principal                  = "secretsmanager.amazonaws.com"
  sg_name_lambda             = "test-lambda"
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
  template_file_name = "custom_policy_kms.json"
  role_name          = "lambsa_sm_role"
  role_service       = ["lambda.amazonaws.com"]
  vpc_id_name        = "/vpc/2/id"
  subnet_id_name     = "/vpc/2/privatesubnet1/id"
}
