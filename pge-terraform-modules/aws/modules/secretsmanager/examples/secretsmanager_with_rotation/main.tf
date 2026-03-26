#
# Filename    : modules/secretsmanager/examples/secretsmanager_with_rotation/main.tf
# Date        : 20 January 2021
# Author      : TCS
# Description : secretsmanager creation main

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  optional_tags      = var.optional_tags
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id_name
}

data "aws_caller_identity" "current" {}


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = var.kms_name
#   description = var.kms_description
#   policy      = templatefile("${path.module}/${var.template_file_name}", { lambda_iam_role = module.aws_lambda_iam_role.arn })
#   tags        = module.tags.tags
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

#########################################
# Create secretsmanager
#########################################
module "secretsmanager" {
  source                     = "../../"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = null                        # replace with module.kms_key.key_arn, after key creation
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = var.secret_string
  secret_version_enabled     = var.secret_version_enabled
  rotation_enabled           = var.rotation_enabled
  rotation_lambda_arn        = module.lambda_function.lambda_qualified_arn
  rotation_after_days        = var.rotation_after_days
  custom_policy              = templatefile("${path.module}/${var.policy_file_name}", { lambda_iam_role = module.aws_lambda_iam_role.arn, aws_region = var.aws_region, account_num = data.aws_caller_identity.current.account_id, secretsmanager_name = var.secretsmanager_name })

  tags = merge(module.tags.tags, local.optional_tags)
}



#While the custom policy for the vpc endpoint the lambda function cloud watch logs will throw errors,
#as the custom policy of the vpc is not allowing the secretsmanager:DescribeSecret action.
#we have tested by giving full access for the vpc endpoint.
module "lambda_function" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = var.lambda_function_name
  source_code = {
    source_dir = "${path.module}/${var.source_dir}"
  }
  description                   = var.lambda_description
  handler                       = var.lambda_handler_name
  runtime                       = var.lambda_runtime
  role                          = module.aws_lambda_iam_role.arn
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  timeout                       = var.timeout
  publish                       = var.publish
  lambda_permission_action      = var.action
  lambda_permission_principal   = var.principal
  environment_variables = {
    variables   = var.environment_variables
    kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  }
  tags = merge(module.tags.tags, local.optional_tags)
}

# Iam role used for the lambda function.
module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.role_name
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [file("${path.module}/lambda_iam_policy.json")]
}

module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.sg_name_lambda
  description        = "Security group for lambda"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}
