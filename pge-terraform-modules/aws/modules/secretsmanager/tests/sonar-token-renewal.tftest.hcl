run "sonar-token-renewal" {
  command = apply

  module {
    source = "./examples/sonar-token-renewal"
  }
}

variables {
  account_num                   = "750713712981"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  kms_role                      = "CloudAdmin"
  vpc_id_name                   = "/vpc/2/id"
  subnet_id1_name               = "/vpc/2/privatesubnet1/id"
  AppID                         = "443"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["m7k3@pge.com", "c1gx@pge.com", "sy10@pge.com"]
  Owner                         = ["m7k3", "c1gx", "sy10"]
  Compliance                    = ["None"]
  Order                         = 8115205
  secretsmanager_name           = "sonar-credentials-tfc"
  secretsmanager_description    = "sonar token renewal with rotation enabled"
  store_as_key_value            = true
  secret_version_enabled        = true
  rotation_enabled              = true
  rotation_after_days           = 83
  recovery_window_in_days       = 0
  kms_name                      = "sonar-token-renewal-tfc"
  kms_description               = "CMK for encrypting sonar token renewal lambda function and secrets manager credentials"
  function_name                 = "sonar-token-renewal"
  description                   = "sonar token renewal lambda function"
  runtime                       = "python3.12"
  handler                       = "lambda_function.lambda_handler"
  source_dir                    = "lambda_source_code"
  lambda_timeout                = 300
  publish                       = true
  sonar_host                    = "https://sonarqube.nonprod.pge.com"
  sonar_token_name_new          = "sonar-nonprod-token"
  secrets_manager_token_keyname = "sonar_token"
  lambda_sg_name                = "sonar-token-renewal-lambda-sg"
  lambda_sg_description         = "Security group for sonar token renwal lambda"
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name              = "sonar-token-renewal-role"
  iam_aws_service       = ["lambda.amazonaws.com"]
  iam_policy_arns       = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
  snstopic_name         = "sonar-token-renewal-notification"
  snstopic_display_name = "sonar token renewal notification sns topic"
  endpoint              = ["m7k3@pge.com"]
  protocol              = "email"
}
