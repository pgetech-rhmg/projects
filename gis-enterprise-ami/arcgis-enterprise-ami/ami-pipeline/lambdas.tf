# Lambda Powertools layer ARN (region-specific)
# See: https://docs.powertools.aws.dev/lambda/python/latest/#lambda-layer

# TODO - replace request layer with locally built layer
locals {
  powertools_layer_arn = "arn:aws:lambda:${data.aws_region.current.region}:017000801446:layer:AWSLambdaPowertoolsPythonV2:68"
  requests_layer_arn   = "arn:aws:lambda:${data.aws_region.current.region}:770693421928:layer:Klayers-p313-requests:2"
}

# AMI Writer Lambda
module "ami_writer_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.4"

  function_name = "ami-factory-ami-writer-${var.environment}"
  role          = module.ami_writer_lambda_iam.arn

  source_code = {
    source_dir = "${path.module}/lambda/ami_writer"
  }

  runtime = "python3.13"
  handler = "app.handler"
  timeout = 60
  layers  = [local.powertools_layer_arn]

  vpc_config_security_group_ids = []
  vpc_config_subnet_ids         = []

  environment_variables = {
    variables = {
      POWERTOOLS_SERVICE_NAME = "ami-writer"
      LOG_LEVEL               = "INFO"
    }
    kms_key_arn = data.aws_ssm_parameter.enterprise_kms.value
  }

  tags = local.merged_tags
}

# TFC Runner Lambda  ###### TODO - replace assumer role with 'data.aws_ssm_parameter.tfc_api_role_arn.value' once we have the parameter from COE #################
module "tfc_runner_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.4"

  function_name = "ami-factory-tfc-runner-${var.environment}"
  role          = module.tfc_runner_lambda_iam.arn

  source_code = {
    source_dir = "${path.module}/lambda/tfc_runner"
  }

  runtime = "python3.13"
  handler = "app.handler"
  timeout = 300
  layers  = [local.powertools_layer_arn, local.requests_layer_arn]

  vpc_config_security_group_ids = [module.image_builder_sg.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]

  environment_variables = {
    variables = {
      TFC_URL                   = var.tfc_url
      TFC_API_ACCESS_ROLE_ARN   = module.test_instance_iam.arn
      TFC_API_TOKEN_SECRET      = var.tfc_api_token_secret_id
      DRY_RUN                   = var.tfc_dry_run ? "true" : "false"
      ENVIRONMENT               = var.environment
      TEST_SUBNET_ID            = data.aws_ssm_parameter.subnet_id1.value
      TEST_SECURITY_GROUP_ID    = module.image_builder_sg.sg_id
      TEST_INSTANCE_TYPE        = var.test_instance_type
      TEST_INSTANCE_PROFILE_ARN = aws_iam_instance_profile.test_instance.arn
      SANDBOX_STATE_PARAMETER   = "/ami_factory/sandbox_state"
      POWERTOOLS_SERVICE_NAME   = "tfc-runner"
      LOG_LEVEL                 = "INFO"
    }
    kms_key_arn = data.aws_ssm_parameter.enterprise_kms.value
  }

  tags = local.merged_tags
}

# Config Manager Lambda
module "config_manager_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.4"

  function_name = "ami-factory-config-manager-${var.environment}"
  role          = module.config_manager_lambda_iam.arn

  source_code = {
    source_dir = "${path.module}/lambda/config_manager"
  }

  runtime = "python3.13"
  handler = "app.handler"
  timeout = 300
  layers  = [local.powertools_layer_arn, local.requests_layer_arn]

  vpc_config_security_group_ids = []
  vpc_config_subnet_ids         = []

  environment_variables = {
    variables = {
      WEBADAPTER_NAME_TAG     = var.webadapter_machinename
      SERVER_NAME_TAG         = var.server_machinename
      DATASTORE_NAME_TAG      = var.datastore_machinename
      PORTAL_NAME_TAG         = var.portal_machinename
      DRY_RUN                 = var.tfc_dry_run ? "true" : "false"
      TFC_URL                 = var.tfc_url
      TFC_API_ACCESS_ROLE_ARN = module.test_instance_iam.arn
      TFC_API_TOKEN_SECRET    = var.tfc_api_token_secret_id
      ARCGIS_VERSION          = var.arcgis_version
      POWERTOOLS_SERVICE_NAME = "config-manager"
      LOG_LEVEL               = "INFO"
    }
    kms_key_arn = data.aws_ssm_parameter.enterprise_kms.value
  }

  tags = local.merged_tags
}

# AMI Publisher Lambda
module "ami_publisher_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.4"

  function_name = "ami-factory-ami-publisher-${var.environment}"
  role          = module.ami_publisher_lambda_iam.arn

  source_code = {
    source_dir = "${path.module}/lambda/ami_publisher"
  }

  runtime = "python3.13"
  handler = "app.handler"
  timeout = 60
  layers  = [local.powertools_layer_arn]

  vpc_config_security_group_ids = []
  vpc_config_subnet_ids         = []

  environment_variables = {
    variables = {
      ENVIRONMENT_NAME        = var.environment
      POWERTOOLS_SERVICE_NAME = "ami-publisher"
      LOG_LEVEL               = "INFO"
    }
    kms_key_arn = data.aws_ssm_parameter.enterprise_kms.value
  }

  tags = local.merged_tags
}

# private lambda for preparing pipeline input (not part of step function)
module "pipeline_input_preparer_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.4"

  function_name = "ami-factory-pipeline-input-preparer-${var.environment}"
  role          = module.pipeline_input_preparer_lambda_iam.arn

  source_code = {
    source_dir = "${path.module}/lambda/input_preparer"
  }

  runtime = "python3.13"
  handler = "app.handler"
  timeout = 60
  layers  = [local.powertools_layer_arn]

  vpc_config_security_group_ids = []
  vpc_config_subnet_ids         = []

  environment_variables = {
    variables = {
      ENVIRONMENT_NAME        = var.environment
      POWERTOOLS_SERVICE_NAME = "pipeline-input-preparer"
      LOG_LEVEL               = "INFO"
    }
    kms_key_arn = data.aws_ssm_parameter.enterprise_kms.value
  }

  tags = local.merged_tags
}
