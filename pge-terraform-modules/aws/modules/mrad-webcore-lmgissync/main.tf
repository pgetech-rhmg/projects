module "gissync_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name                 = local.lambda_name
  description                   = "Engage GIS Sync"
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

resource "aws_sqs_queue" "gissync" {
  name                       = "${local.prefix}-${local.short_name}-queue-${local.suffix}"
  message_retention_seconds  = 1209600 // 14 days
  visibility_timeout_seconds = 1200    // 20 minutes
  kms_master_key_id          = "alias/s3-sns-sqs"
  tags                       = var.tags

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.gissync_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "gissync_dlq" {
  name                       = "${local.prefix}-${local.short_name}-dlq-${local.suffix}"
  message_retention_seconds  = 1209600 // 14 days
  visibility_timeout_seconds = 60
  kms_master_key_id          = "alias/s3-sns-sqs"
  tags                       = var.tags
}

resource "aws_sqs_queue_policy" "sqs_permission" {
  queue_url = aws_sqs_queue.gissync.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal":  {
        "AWS": [
            "${local.account_num}"
        ]
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.gissync.arn}"
    },
    {
      "Sid": "DenyNonSecureAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.gissync.arn}",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_lambda_event_source_mapping" "gissync_event_source" {
  event_source_arn = aws_sqs_queue.gissync.arn
  function_name    = module.gissync_lambda.lambda_arn
  batch_size       = 1
}

module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.10"
  name    = "/aws/lambda/${local.prefix}-${local.short_name}-${local.suffix}"
  tags    = var.tags
}

module "tfcrun_sumo" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
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
