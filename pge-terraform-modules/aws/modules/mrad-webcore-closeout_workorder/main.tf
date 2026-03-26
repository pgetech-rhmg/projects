module "engage_closeout_workorder_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name                = local.lambda_name
  description                  = "Engage Closeout Workorder Lambda function that runs every 48 hours"
  memory_size                  = "256"
  timeout                      = "900"
  runtime                      = "nodejs22.x"
  handler                      = "src/index.handler"
  tags                         = var.tags
  vpc_config_security_group_ids = [data.aws_security_group.lambda_sg.id]
  vpc_config_subnet_ids        = [data.aws_subnet.mrad1.id, data.aws_subnet.mrad2.id, data.aws_subnet.mrad3.id]
  role                         = aws_iam_role.lambda_role.arn
  source_code_hash             = data.aws_s3_object.lambda_zip.checksum_sha256

  # Lambda is pulled from an S3 bucket:
  s3_bucket = local.s3_bucket
  s3_key    = local.s3_key

  # NODE_ENV is one of dev, qa, or production
  environment_variables = {
    "kms_key_arn" : null,
    "variables" : {
      NODE_ENV                  = "${var.node_env}"
      AWS_LAMBDA_EXEC_WRAPPER   = "/opt/otel-handler"
      OTEL_TRACES_SAMPLER       = "always_on"
      OTEL_SERVICE_NAME         = local.lambda_name
      SUMO_OTLP_HTTP_ENDPOINT_URL = local.sumologic_endpoint
      OTEL_RESOURCE_ATTRIBUTES    = "application=${local.short_name},deployment.environment=${local.suffix},cloud.account.id=${local.account_num}"
    }
  }

  layers = [
    local.sumo_layer_arn,
    data.aws_lambda_layer_version.cloud_utilities.arn
  ]
}

# CloudWatch Event Rule for every 6 pm PST schedule
resource "aws_cloudwatch_event_rule" "engage_closeout_workorder_schedule" {
  name                = "${var.prefix}-${local.short_name}-schedule-rule-${lower(var.suffix)}"
  schedule_expression = local.run_on_daily_6pm.schedule_expression
  description         = "Event rule for ${local.project_name} Lambda - runs every 6 pm evening PST"
  state               = "ENABLED"
  tags                = var.tags
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "engage_closeout_workorder_schedule" {
  rule      = aws_cloudwatch_event_rule.engage_closeout_workorder_schedule.id
  arn       = module.engage_closeout_workorder_lambda.lambda_arn
  target_id = "${var.prefix}-${local.short_name}-target-${lower(var.suffix)}"
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "engage_closeout_workorder_schedule" {
  statement_id  = "${var.prefix}-${local.short_name}-schedule-${lower(var.suffix)}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.prefix}-${local.short_name}-${lower(var.suffix)}"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.engage_closeout_workorder_schedule.arn
}

# CloudWatch Log Group
module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.10"

  name    = "/aws/lambda/${var.prefix}-${local.short_name}-${lower(var.suffix)}"
  tags    = var.tags
}

# SumoLogic Integration
module "pttup_sumo" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "0.0.11"

  http_source_name = "sumo-${var.prefix}-${local.short_name}-${lower(var.suffix)}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.lambda_logs.cloudwatch_log_group_name
  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator    = "${var.prefix}-${local.short_name}"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.git_branch
}
