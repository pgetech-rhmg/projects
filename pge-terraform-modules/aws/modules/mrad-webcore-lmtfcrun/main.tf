module "tfcrun_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket"
  version = "0.1.4"

  function_name                 = "${var.prefix}-${local.short_name}-${lower(local.envname)}"
  description                   = "Run TFC workspaces"
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

module "lambda_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.10"
  name    = "/aws/lambda/${var.prefix}-${local.short_name}-${lower(local.envname)}"
  tags    = var.tags
}

resource "aws_lambda_permission" "tfcrun_lambda" {
  statement_id  = "${var.prefix}-${local.short_name}-s3-${lower(local.envname)}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.prefix}-${local.short_name}-${lower(local.envname)}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.s3_bucket}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = local.s3_bucket

  lambda_function {
    lambda_function_arn = module.tfcrun_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.tfcrun_lambda,
    module.tfcrun_lambda
  ]
}

module "tfcrun_sumo" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version          = "~> 3.0.2"

  http_source_name = "sumo-${var.prefix}-${local.short_name}-${lower(local.envname)}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.lambda_logs.cloudwatch_log_group_name

  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator                        = "${var.prefix}-tfcrun"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.git_branch
}
