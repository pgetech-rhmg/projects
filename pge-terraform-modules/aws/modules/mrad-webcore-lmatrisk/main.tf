module "atrisk_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name                 = local.lambda_name
  description                   = "Update workorder statuses to At Risk"
  memory_size                   = "256"
  timeout                       = "900"
  runtime                       = "nodejs22.x"
  handler                       = "src/index.handler"
  tags                          = var.tags
  vpc_config_security_group_ids = [data.aws_security_group.lambda_sg.id]
  vpc_config_subnet_ids         = [data.aws_subnet.mrad1.id, data.aws_subnet.mrad2.id, data.aws_subnet.mrad3.id]
  role                          = aws_iam_role.lambda_role.arn

  # Lambda is pulled from an S3 bucket:
  s3_bucket = local.s3_bucket
  s3_key    = aws_s3_object.lambda_zip.key

  # NODE_ENV is one of dev, qa, or production
  environment_variables = {
    "kms_key_arn" : null,
    "variables" : {
      NODE_ENV                    = local.node_env
      SUFFIX                      = local.suffix
      PREFIX                      = local.prefix
      SHORT_NAME                  = local.short_name
      AWS_LAMBDA_EXEC_WRAPPER     = "/opt/otel-handler"
      OTEL_TRACES_SAMPLER         = "always_on"
      OTEL_SERVICE_NAME           = local.lambda_name
      SUMO_OTLP_HTTP_ENDPOINT_URL = local.sumologic_endpoint
      OTEL_RESOURCE_ATTRIBUTES    = "application=${local.short_name},deployment.environment=${local.suffix},cloud.account.id=${local.account_num}"
    }
  }
  layers = [
    local.sumo_layer_arn,
    data.aws_lambda_layer_version.cloud_utilities.arn
  ]
}

# from TerraformCWRulesModule
resource "aws_cloudwatch_event_rule" "atrisk" {
  name                = "${local.lambda_name}-rule"
  schedule_expression = local.event_rule_config.schedule_expression
  description         = "Event rule for ${local.short_name} Lambda"
  state               = "ENABLED"
  tags                = var.tags
}

# from TerraformCWRulesModule
resource "aws_cloudwatch_event_target" "target_lambda" {
  rule      = aws_cloudwatch_event_rule.atrisk.id
  arn       = module.atrisk_lambda.lambda_arn
  target_id = "${local.lambda_name}-target"
}

resource "aws_lambda_permission" "atrisk" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.atrisk.arn
}

module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.2"
  name    = "/aws/lambda/${local.lambda_name}"
  tags    = var.tags
}

module "atrisk_sumo" {
  source           = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "0.0.11"

  http_source_name = "sumo-${local.lambda_name}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.lambda_logs.cloudwatch_log_group_name

  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator                        = local.lambda_name
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.git_branch
}
