run "git-token-renewal-notification" {
  command = apply

  module {
    source = "./examples/git-token-renewal-notification"
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
  secretsmanager_name        = "git-credentials-test"
  secretsmanager_description = "git pat"
  store_as_key_value         = true
  secret_version_enabled     = true
  recovery_window_in_days    = 0
  kms_name                   = "git-token-renewal-notification"
  kms_description            = "CMK for encrypting git token renewal notification lambda function and secrets manager credentials"
  function_name              = "git-token-renewal-notification"
  description                = "git token renewal remainder notification lambda function"
  runtime                    = "python3.12"
  handler                    = "lambda_function.lambda_handler"
  source_dir                 = "lambda_source_code"
  lambda_timeout             = 300
  publish                    = true
  lambda_sg_name             = "git-token-renewal-lambda-sg"
  lambda_sg_description      = "Security group for git token renewal notification lambda"
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name                          = "git-token-renewal-notification-role"
  iam_aws_service                   = ["lambda.amazonaws.com"]
  iam_policy_arns                   = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite", "arn:aws:iam::aws:policy/AmazonSNSFullAccess"]
  cloudwatch_event_rule_name        = "git-token-renewal-notification"
  cloudwatch_event_rule_description = "event to trigger with cron expression to notify renewwal of git token"
  cron_schedule_expression          = "rate(2 days)"
  snstopic_name                     = "git-token-renewal-notification"
  snstopic_display_name             = "git-token-renewal-notification sns topic"
  endpoint                          = ["m7k3@pge.com"]
  protocol                          = "email"
}
