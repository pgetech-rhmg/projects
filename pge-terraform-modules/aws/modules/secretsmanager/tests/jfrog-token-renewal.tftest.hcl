run "jfrog-token-renewal" {
  command = apply

  module {
    source = "./examples/jfrog-token-renewal"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  kms_role                   = "CloudAdmin"
  vpc_id_name                = "/vpc/2/id"
  subnet_id1_name            = "/vpc/2/privatesubnet1/id"
  AppID                      = "443"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["m7k3@pge.com", "c1gx@pge.com", "sy10@pge.com"]
  Owner                      = ["m7k3", "c1gx", "sy10"]
  Compliance                 = ["None"]
  Order                      = 8115205
  secretsmanager_name        = "test-jfrog-token"
  secretsmanager_description = "jfrog token renewal with rotation enabled"
  secret_version_enabled     = true
  rotation_enabled           = true
  rotation_after_days        = 70
  recovery_window_in_days    = 0
  kms_name                   = "jfrog-token-renewal"
  kms_description            = "CMK for encrypting jfrog token renewal lambda function and secrets manager credentials"
  function_name              = "jfrog-token-renewal"
  description                = "jfrog token renewal lambda function"
  runtime                    = "python3.12"
  handler                    = "lambda_function.lambda_handler"
  source_dir                 = "lambda_source_code"
  lambda_timeout             = 300
  publish                    = true
  jfrog_host                 = "https://jfrog.nonprod.pge.com"
  lambda_sg_name             = "jfrog-token-renewal-lambda-sg"
  lambda_sg_description      = "Security group for jfrog token renwal lambda"
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name              = "jfrog-token-renewal-role"
  iam_aws_service       = ["lambda.amazonaws.com"]
  iam_policy_arns       = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
  snstopic_name         = "jfrog-token-renewal-notification"
  snstopic_display_name = "jfrog token renewal notification sns topic"
  endpoint              = ["m7k3@pge.com"]
  protocol              = "email"
}
