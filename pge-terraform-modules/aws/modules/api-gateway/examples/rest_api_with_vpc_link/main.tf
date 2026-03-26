/*
* # AWS API Gateway Rest api with vpc link  user module example
* Terraform module which creates SAF2.0 API Gateway in AWS
*/

#  Filename    : aws/modules/api-gateway/examples/rest_api_with_vpc_link/main.tf
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

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
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

  #aws_api_gateway_model
  model_name         = var.model_name
  model_content_type = var.model_content_type
  model_schema       = var.model_schema

  #aws_api_gateway_gateway_response
  gateway_response_type = var.gateway_response_type

  #aws_api_gateway_client_certificate
  api_gateway_client_certificate_create = var.api_gateway_client_certificate_create
  client_certificate_description        = var.client_certificate_description

  #aws_api_gateway_documentation_part
  documentation_part_properties = var.documentation_part_properties
  location_method               = var.location_method
  location_type                 = var.location_type
  location_path                 = var.location_path

  #aws_api_gateway_documentation_version
  documentation_version     = var.documentation_version
  documentation_description = var.documentation_description

  #aws_api_gateway_vpc_link
  vpc_link_name        = var.vpc_link_name
  vpc_link_target_arns = [aws_lb.example.arn]
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
  rest_api_id                 = module.api_gateway_resource.api_gateway_rest_api_id
  resource_id                 = module.api_resource.api_gateway_resource_id
  method_http_method          = var.method_http_method
  method_request_validator_id = module.api_gateway_request_validator.api_gateway_request_validator_id
  method_request_parameters   = var.method_request_parameters

  #aws_api_gateway_method_response
  method_response_status_code = var.method_response_status_code

  #aws_api_gateway_integration
  integration_type                 = var.integration_type
  integration_connection_type      = var.integration_connection_type
  integration_connection_id        = module.api_gateway_resource.api_gateway_vpc_link_id
  integration_http_method          = var.integration_http_method
  integration_uri                  = var.integration_uri
  integration_request_templates    = var.integration_request_templates
  integration_content_handling     = var.integration_content_handling
  integration_passthrough_behavior = var.integration_passthrough_behavior
  integration_cache_key_parameters = var.integration_cache_key_parameters
  integration_cache_namespace      = var.integration_cache_namespace

  #aws_api_gateway_integration_response
  api_gateway_integration_response_create = var.api_gateway_integration_response_create
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

data "aws_iam_policy_document" "allow-lb" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com", "delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.lb-logs.arn}/*",
      "${aws_s3_bucket.lb-logs.arn}"
    ]
   
  }
 statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::797873946194:root"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]     
    resources = [
      "${aws_s3_bucket.lb-logs.arn}/*",
      "${aws_s3_bucket.lb-logs.arn}"
    ]
  }
  

}

resource "aws_s3_bucket_policy" "allow-lb" {
  bucket = aws_s3_bucket.lb-logs.id
  policy = data.aws_iam_policy_document.allow-lb.json
}
resource "aws_s3_bucket" "lb-logs" {
  bucket = "a8q-alb-s3-logs-example-ccoe"
}

resource "aws_lb" "example" {
  name                             = "api-examplelb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id = data.aws_ssm_parameter.subnet_id3.value
  }

  access_logs {
    bucket  = var.alb_s3_bucket_name
    enabled = true
  }

  tags = merge(module.tags.tags, local.optional_tags)
}