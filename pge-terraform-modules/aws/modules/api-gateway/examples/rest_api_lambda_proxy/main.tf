/*
* # AWS API Gateway Rest api Lambda Proxy Integration user module example
* Terraform module which creates SAF2.0 API Gateway in AWS
*/

#  Filename    : aws/modules/api-gateway/examples/rest_api_lambda_proxy/main.tf
#  Date        : 22 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

#########################################
# Create API Gateway Resource
#########################################
module "api_gateway_resource" {
  source = "../../modules/rest_api"

  #api_gateway_rest_api
  rest_api_name                           = var.rest_api_name
  rest_api_description                    = var.rest_api_description
  endpoint_configuration_vpc_endpoint_ids = [var.pVpcEndpoint]
  policy                                  = data.aws_iam_policy_document.api_policy.json
  tags                                    = merge(module.tags.tags, local.optional_tags)
}

module "api_gateway_request_validator" {
  source = "../../modules/rest_api_request_validator"

  #aws_api_gateway_request_validator
  rest_api_id                                   = module.api_gateway_resource.api_gateway_rest_api_id
  request_validator_name                        = var.request_validator_name
  request_validator_validate_request_parameters = var.request_validator_validate_request_parameters
}

module "api_resource" {
  source = "../../modules/rest_api_resource"

  #aws_api_gateway_resource
  api_gateway_rest_api_id = module.api_gateway_resource.api_gateway_rest_api_id
  api_gateway_parent_id   = module.api_gateway_resource.api_gateway_rest_api_root_resource_id
  api_gateway_path_part   = var.resource_path_part
}

module "api_gateway_method" {
  source = "../../modules/rest_api_method"

  #aws_api_gateway_method
  rest_api_id        = module.api_gateway_resource.api_gateway_rest_api_id
  resource_id        = module.api_resource.api_gateway_resource_id
  method_http_method = var.method_http_method
  authorization = {
    method_authorization    = var.method_authorization
    method_authorization_id = module.api_gateway_authorizer.api_gateway_authorizer_id
    api_key_required        = var.api_key_required
    cors_enabled            = var.cors_enabled
  }
  method_request_validator_id = module.api_gateway_request_validator.api_gateway_request_validator_id
  method_request_parameters   = var.method_request_parameters

  #aws_api_gateway_method_response
  method_response_status_code = var.method_response_status_code

  #aws_api_gateway_integration
  integration_type                 = var.integration_type
  integration_http_method          = var.integration_http_method
  integration_uri                  = module.lambda_function.lambda_invoke_arn
  integration_content_handling     = var.integration_content_handling
  integration_connection_type      = var.integration_connection_type
  integration_cache_key_parameters = var.integration_cache_key_parameters
  integration_cache_namespace      = var.integration_cache_namespace
  integration_request_parameters   = var.integration_request_parameters

  #aws_api_gateway_integration_response
  api_gateway_integration_response_create = var.api_gateway_integration_response_create
}

module "api_gateway_key" {
  source = "../../"

  #aws_api_gateway_key
  api_key_name = var.api_key_name
  tags         = merge(module.tags.tags, local.optional_tags)
}

module "api_gateway_usage_plan" {
  source = "../../modules/api_usage_plan"

  #aws_api_gateway_usage_plan
  usage_plan_name        = var.usage_plan_name
  usage_plan_description = var.usage_plan_description
  tags                   = merge(module.tags.tags, local.optional_tags)
  api_stages = [
    {
      api_id = module.api_gateway_resource.api_gateway_rest_api_id
      stage  = module.api_gateway_stage.api_gateway_stage_name
    }
  ]

  #aws_api_gateway_usage_plan_key
  usage_plan_key_id   = module.api_gateway_key.api_gateway_api_key_id
  usage_plan_key_type = var.usage_plan_key_type
}


data "aws_iam_policy_document" "api_policy" {
  source_policy_documents = [
    templatefile("${path.module}/policy.json",
      {
        pVpcEndpoint = var.pVpcEndpoint
    }, )
  ]
}



module "api_gateway_stage" {
  source = "../../modules/rest_api_deployment_and_stage"

  #aws_api_gateway_deployment
  rest_api_id = module.api_gateway_resource.api_gateway_rest_api_id
  depends_on  = [module.api_gateway_resource, module.api_resource, module.api_gateway_method]

  #aws_api_gateway_stage
  stage_name                  = var.stage_name
  stage_description           = var.stage_description
  stage_cache_cluster_enabled = var.stage_cache_cluster_enabled
  stage_cache_cluster_size    = var.stage_cache_cluster_size
  tags                        = merge(module.tags.tags, local.optional_tags)

  #aws_api_gateway_method_settings
  method_settings_method_path = var.method_settings_method_path
  settings_logging_level      = var.settings_logging_level
}

module "lambda_function" {
   source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"
  
  function_name = var.function_name
  role          = module.aws_lambda_iam_role.arn
  handler       = var.handler
  runtime       = var.runtime
  source_code = {
    source_dir = "${path.module}/${var.local_zip_source_directory}"
  }
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  tags                          = merge(module.tags.tags, local.optional_tags)
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.account_num}:${module.api_gateway_resource.api_gateway_rest_api_id}/*/GET/resource"
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}

module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.lambda_sg_name
  description        = var.lambda_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules  = var.lambda_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "api_gateway_authorizer" {
  source = "../../modules/rest_api_authorizer"

  #aws_api_gateway_authorizer
  rest_api_id                               = module.api_gateway_resource.api_gateway_rest_api_id
  authorizer_name                           = var.authorizer_name
  authorizer_uri                            = module.lambda_function_authorization.lambda_invoke_arn
  authorizer_credentials                    = module.authorizer_iam_role.arn
  authorizer_identity_validation_expression = var.authorizer_identity_validation_expression
}

module "lambda_function_authorization" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = var.auth_function_name
  role          = module.aws_lambda_iam_role.arn
  handler       = var.auth_handler
  runtime       = var.auth_runtime
  source_code = {
    source_dir = "${path.module}/${var.auth_local_zip_source_directory}"
  }
  vpc_config_security_group_ids = [module.security_group_auth_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  tags                          = merge(module.tags.tags, local.optional_tags)
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

module "authorizer_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = var.authorizer_iam_name
  aws_service   = var.authorizer_iam_aws_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [data.aws_iam_policy_document.inline_policy.json]
}

module "security_group_auth_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.auth_lambda_sg_name
  description        = var.lambda_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules  = var.lambda_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}