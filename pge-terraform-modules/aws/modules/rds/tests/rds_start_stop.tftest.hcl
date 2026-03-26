run "rds_start_stop" {
  command = apply

  module {
    source = "./examples/rds_start_stop"
  }
}

variables {
  aws_role                            = "CloudAdmin"
  account_num                         = "750713712981"
  user                                = "rb1c"
  aws_region                          = "us-west-2"
  AppID                               = "1001"
  Environment                         = "Dev"
  DataClassification                  = "Internal"
  CRIS                                = "Low"
  Notify                              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                               = ["abc1", "def2", "ghi3"]
  Compliance                          = ["None"]
  Order                               = 8115205
  role_service_rds_auto_start_stop    = ["lambda.amazonaws.com"]
  iam_policy_arns_rds_auto_start_stop = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  /********************************************** RDS Auto Start Stop service *********************************************/
  rds_auto_control_service_name = "ccoe-rds-auto-start-stop"
  lambda_runtime                = "python3.11"
  lambda_timeout                = 610
  lambda_sg_description         = "Security group for python lambda function for Auto start stop the RDS Instance"
  schedule_rds_auto_start       = "cron(32 12 ? * MON *)"
  schedule_rds_auto_stop        = "cron(40 21 ? * * *)"
  service_name                  = "com.amazonaws.us-west-2.rds"
}
