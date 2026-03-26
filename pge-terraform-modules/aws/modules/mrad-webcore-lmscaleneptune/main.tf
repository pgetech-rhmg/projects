module "neptune_scale_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name = local.lambda_name
  description   = "Scale Neptune read replicas based on SSM parameter triggers"
  memory_size   = "256"
  timeout       = "900"
  runtime       = "nodejs22.x"
  handler       = "src/index.handler"
  tags          = var.tags

  vpc_config_security_group_ids = [data.aws_security_group.lambda_sg.id]
  vpc_config_subnet_ids         = [data.aws_subnet.mrad1.id, data.aws_subnet.mrad2.id, data.aws_subnet.mrad3.id]
  role                          = aws_iam_role.lambda_role.arn

  # Lambda is pulled from an S3 bucket:
  s3_bucket = local.s3_bucket
  s3_key    = aws_s3_object.lambda_zip.key

  # Environment variables
  environment_variables = {
    "kms_key_arn" : null,
    "variables" : {
      # Core Lambda variables
      LOG_LEVEL                 = local.account_num == "990878119577" ? "DEBUG" : "INFO"
      NODE_ENV                  = local.node_env
      SUFFIX                    = local.suffix
      PREFIX         = local.prefix
      SHORT_NAME     = local.short_name
      INSTANCE_CLASS = "db.r6g.large"
      
      # OpenTelemetry and SumoLogic configuration (used by Lambda layers)
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

module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.2"

  name = "/aws/lambda/${local.lambda_name}"
  tags = var.tags
}

module "neptune_scale_sumo" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "0.0.11"

  http_source_name = "sumo-${local.lambda_name}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.lambda_logs.cloudwatch_log_group_name

  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator                    = local.lambda_name
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.git_branch
}

# SSM Parameter for triggering Neptune scale
resource "aws_ssm_parameter" "neptune_scale_trigger" {
  name        = "/${local.prefix}/neptune-scale/trigger-${local.suffix}"
  description = "Neptune Scale trigger: 'CLUSTER-Name:ADD_NODE/DELETE_NODE:AZ'e.g engage-neptune-predev:ADD_NODE:US-east1a to add and engage-neptune-predev:DELETE_NODE:US-east1a  for replicas, 'CLUSTER-Name:DELETE_CLUSTER:CONFIRM' e.g engage-neptune-predev:DELETE:CONFIRM for full deletion, 'idle' for no action."
  type        = "String"
  value       = "idle"
  tier        = "Advanced"  # Required for EventBridge notifications
  
  tags = merge(var.tags, {
    Purpose = "Neptune Scale Trigger"
  })

  lifecycle {
    ignore_changes = [value]
  }
}

# CloudWatch Event Rule for Parameter Store changes
resource "aws_cloudwatch_event_rule" "parameter_change" {
  name        = "neptune-scale-parameter-change-${local.suffix}"
  description = "Trigger Neptune scale Lambda when parameter changes"

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Parameter Store Change"]
    resources   = [
      "arn:aws:ssm:us-west-2:${local.account_num}:parameter/${local.prefix}/neptune-scale/trigger-${local.suffix}"
    ]
    detail = {
      operation = [
        "Create",
        "Update",
        "Delete",
        "LabelParameterVersion"
      ]
    }
  })

  tags = var.tags
}

# Lambda permission to allow EventBridge to invoke Lambda directly
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.parameter_change.arn
}

# EventBridge target to invoke Lambda directly
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.parameter_change.name
  target_id = "InvokeLambda"
  arn       = module.neptune_scale_lambda.lambda_arn
}