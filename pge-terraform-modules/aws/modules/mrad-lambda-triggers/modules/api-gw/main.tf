/*
 * # AWS Lambda trigger module 
 * Composite module usind SAF2.0 CCoE modules
*/
#
#  Filename    : aws/modules/mrad-lambda-triggers/modules/api-gw/main.tf
#  Date        : 02 June 2023
#  Author      : MRAD (mrad@pge.com)
#  Description : LAMBDA trigger terraform module creates a Lambda trigger using a rest api
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sumologic = {
      source = "SumoLogic/sumologic"
      version = ">= 2.1.2"
      configuration_aliases = [sumologic]
    }
  }
}

module "api_gateway" {
  source  = "app.terraform.io/pgetech/api-gateway/aws//modules/rest_api"
  version = "0.0.14"

  #api_gateway_rest_api
  rest_api_name                           = var.name
  endpoint_configuration_vpc_endpoint_ids = [data.aws_vpc_endpoint.apigw.id]
  policy                                  = var.api_gw_resource_policy
  rest_api_binary_media_types             = var.binary_media_types
  tags                                    = var.tags
}


module "api_deployment_and_stage" {
  source  = "app.terraform.io/pgetech/api-gateway/aws//modules/rest_api_deployment_and_stage"
  version = "0.0.14"

  rest_api_id = module.api_gateway.api_gateway_rest_api_id

  # Deployment
  deployment_triggers = {
    redeployment = sha1(join(",", var.deployment_triggers))
  }

  # Stage
  stage_name                 = lower(var.aws_account)
  stage_xray_tracing_enabled = var.tracing_enabled

  # Method Settings
  method_settings_method_path = "*/*"
  settings_logging_level      = "INFO"

  tags = var.tags
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${module.api_gateway.api_gateway_rest_api_id}/*"
}

 module "sumo_logger" {
  source  = "app.terraform.io/pgetech/mrad-sumo/aws"
  version = "3.0.9-rc1"

  providers = {
    sumologic = sumologic
  }

  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.branch
  aws_account                          = var.aws_account
  aws_role                             = var.aws_role
  tags                                 = var.tags
  log_group_name                       = module.cloudwatch_log_group.cloudwatch_log_group_name
}

module "cloudwatch_log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.0.8"

  name = "API-Gateway-Execution-Logs_${module.api_gateway.api_gateway_rest_api_id}/${lower(var.aws_account)}"

  tags = var.tags
}



