/*
 * # AWS CodeDeploy Lambda_canary deployment User module example
*/
#
#  Filename    : aws/modules/codedeploy/examples/lambda_canary/main.tf
#  Date        : 5 July 2022
#  Author      : TCS
#  Description : The terraform module creates a lambda canary deployment


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

#########################################
# Supporting Resources
#########################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

# The resource random_string generates a random permutation of alphanumeric characters
resource "random_string" "random" {
  length  = 5
  special = false
}

#########################################
# Create codedeploy_app_lambda
#########################################

module "codedeploy_app_lambda" {
  source = "../.."

  codedeploy_app_name             = "${var.codedeploy_app_name}-${random_string.random.result}"
  codedeploy_app_compute_platform = var.codedeploy_app_compute_platform
  tags                            = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create deployment_config_lambda
#########################################
module "deployment_config_lambda" {
  source = "../../modules/codedeploy_deployment_config"

  deployment_config_name             = "${var.deployment_config_name}-${random_string.random.result}"
  deployment_config_compute_platform = var.deployment_config_compute_platform
  traffic_routing_config             = var.traffic_routing_config
}

#########################################
# Create deployment_group_lambda
#########################################

module "deployment_group" {
  source = "../../modules/deployment_group"

  deployment_group_app_name         = module.codedeploy_app_lambda.codedeploy_app_name
  deployment_group_name             = "${var.deployment_group_name}-${random_string.random.result}"
  deployment_group_service_role_arn = module.deployment_group_role.arn
  deployment_config_name            = module.deployment_config_lambda.deployment_group_config_name
  tags                              = merge(module.tags.tags, local.optional_tags)
  deployment_style = [{
    deployment_type   = var.deployment_type
    deployment_option = var.deployment_option
  }]
}

module "deployment_group_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.role_name}-${random_string.random.result}"
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.policy_arns
}

module "vpc_endpoint_code_deploy_api" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  private_dns_enabled = true
  service_name        = var.api_service_name
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value]
  security_group_ids  = [module.security_group_vpc_endpoint.sg_id]
  tags                = merge(module.tags.tags, local.optional_tags)
}

module "security_group_vpc_endpoint" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.vpc_endpoint_sg_name
  description        = var.vpc_endpoint_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.vpc_endpoint_cidr_ingress_rules
  cidr_egress_rules  = var.vpc_endpoint_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}
