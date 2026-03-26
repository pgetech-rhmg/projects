module "gisseed_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name                 = "${var.prefix}-${local.short_name}-${lower(local.envname)}"
  description                   = "Engage GIS Seed"
  memory_size                   = "256"
  timeout                       = "900"
  runtime                       = "nodejs22.x"
  handler                       = "src/index.handler"
  tags                          = var.tags
  vpc_config_security_group_ids = [data.aws_security_group.lambda_sg.id]
  vpc_config_subnet_ids         = [data.aws_subnet.mrad1.id, data.aws_subnet.mrad2.id, data.aws_subnet.mrad3.id]
  role                          = aws_iam_role.lambda_role.arn
  source_code_hash              = data.aws_s3_object.lambda_zip.checksum_sha256

  # Lambda is pulled from an S3 bucket:
  s3_bucket = local.s3_bucket
  s3_key    = local.s3_key

  # NODE_ENV is one of dev, qa, or production
  environment_variables = {
    "kms_key_arn" : null,
    "variables" : {
      NODE_ENV                    = local.node_env
      AWS_LAMBDA_EXEC_WRAPPER     = "/opt/otel-handler"
      OTEL_TRACES_SAMPLER         = "always_on"
      OTEL_SERVICE_NAME           = "${var.prefix}-${local.short_name}-${lower(local.envname)}"
      SUMO_OTLP_HTTP_ENDPOINT_URL = local.sumologic_endpoint
      OTEL_RESOURCE_ATTRIBUTES    = "application=${local.short_name},deployment.environment=${lower(local.envname)},cloud.account.id=${local.account_num}"
    }
  }
  layers = [
    local.sumo_layer_arn,
    data.aws_lambda_layer_version.cloud_utilities.arn
  ]
}

resource "aws_sns_topic" "gisseed" {
  name = "${var.prefix}-${local.short_name}-${lower(local.envname)}"
  tags = var.tags
}

resource "aws_sqs_queue" "gisseed_queue" {
  name                       = "${var.prefix}-${local.short_name}-queue-${lower(local.envname)}"
  policy                     = data.aws_iam_policy_document.sqs_policy_document.json
  tags                       = var.tags
  message_retention_seconds  = 1209600 // 14 days
  visibility_timeout_seconds = 1200    // 20 minutes
}

resource "aws_lambda_event_source_mapping" "event_source" {
  event_source_arn = aws_sqs_queue.gisseed_queue.arn
  function_name    = module.gisseed_lambda.lambda_arn
  batch_size       = 1
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.gisseed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.gisseed_queue.arn
}

data "aws_iam_policy_document" "sqs_policy_document" {
  statement {
    actions   = ["sqs:*"]
    resources = ["arn:aws:sqs:${local.region}:${local.account_num}:${var.prefix}-${local.short_name}-queue-${lower(local.envname)}"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.gisseed.arn, "arn:aws:sqs:${local.region}:${local.account_num}:${var.prefix}-${local.short_name}-queue-${lower(local.envname)}"]
    }
  }
}

resource "aws_ssm_parameter" "gis_endpoint" {
  name        = "/${var.prefix}/gis-seed-gis-endpoint"
  type        = "String"
  value       = local.gis_seed_gis_endpoint
  description = "The current GIS endpoint that the lambda will use"
  tags        = var.tags

  # This parameter may be modified through the AWS web console
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.10"
  name    = "/aws/lambda/${var.prefix}-${local.short_name}-${lower(local.envname)}"
  tags    = var.tags
}

module "pttup_sumo" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "0.0.11"
  runtime = "nodejs22.x"

  http_source_name = "sumo-${var.prefix}-${local.short_name}-${lower(local.envname)}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.lambda_logs.cloudwatch_log_group_name
  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator                        = "${var.prefix}-${local.short_name}"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.git_branch
}
