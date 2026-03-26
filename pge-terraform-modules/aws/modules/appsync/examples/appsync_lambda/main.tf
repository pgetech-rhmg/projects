/*
 * # AWS AppSync example
 * # Terraform module example usage for AppSync with Lambda as Datasource
*/
#
#  Filename    : aws/modules/appsync/examples/appsync_lambda/main.tf
#  Date        : 29 Sep 2022
#  Author      : TCS
#  Description : The Terraform module creates AppSync with Lambda as Datasource

locals {
  name = "${var.name}_${random_string.name.result}"
  Order    = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

#Supporting Resource
data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_subnet" "appsync_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "appsync_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "appsync_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "graphql_api" {
  source = "../../"

  authentication_type = var.authentication_type
  openid_connect_config = {
    issuer    = var.issuer
    client_id = var.client_id
  }
  name                     = local.name
  schema                   = file("${path.module}/schema.graphql")
  xray_enabled             = var.xray_enabled
  visibility               = var.visibility
  web_acl_arn              = var.web_acl_arn
  cloudwatch_logs_role_arn = module.graphql_api_iam_role.arn
  additional_authentication_provider = [{
    authentication_type = var.additional_authentication_provider_authentication_type
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

#graphql_api
module "graphql_api_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = "custom-${local.name}"
  aws_service   = var.domain_role_service
  tags          = merge(module.tags.tags, var.optional_tags)
  inline_policy = [file("${path.module}/cloudwatch.json")]
}

#appsync_datasource
module "datasource" {
  source = "../../modules/datasource"

  api_id           = module.graphql_api.id
  name             = local.name
  service_role_arn = module.graphql_api_iam_role.arn
  config = {
    type = var.type
    lambda_config = {
      function_arn = module.lambda_function.lambda_arn
    }
  }
}

module "appsync_domain_name" {
  count  = var.visibility != "PRIVATE" ? 1 : 0
  source = "../../modules/domain_name"

  certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
}

module "appsync_domain_name_api_association" {
  count  = var.visibility != "PRIVATE" ? 1 : 0
  source = "../../modules/domain_name_api_association"

  api_id      = module.graphql_api.id
  domain_name = module.appsync_domain_name[0].domain_name_id
}

module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = local.name
  role          = module.graphql_api_iam_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    content  = var.content
    filename = var.filename
  }
  tags                          = merge(module.tags.tags, var.optional_tags)
  vpc_config_security_group_ids = [module.security_group.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.appsync_1.cidr_block, data.aws_subnet.appsync_2.cidr_block, data.aws_subnet.appsync_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.appsync_1.cidr_block, data.aws_subnet.appsync_2.cidr_block, data.aws_subnet.appsync_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "function" {
  source = "../../modules/function"

  name                      = local.name
  api_id                    = module.graphql_api.id
  data_source               = module.datasource.name
  max_batch_size            = var.max_batch_size
  request_mapping_template  = var.request_mapping_template
  response_mapping_template = var.response_mapping_template
}

module "resolver" {
  source = "../../modules/resolver"

  api_id            = module.graphql_api.id
  type              = var.resolver_type
  field             = var.field
  request_template  = var.request_template
  response_template = var.response_template
  kind              = var.kind
  pipeline_config = {
    functions = [module.function.function_id]
  }
}