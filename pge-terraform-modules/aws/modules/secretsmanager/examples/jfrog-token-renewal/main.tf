/*
 * #### A Reference to rotate Jfrog  Access Token using Refresh Token
 *
 * **What this code does:** 
 * - Updates provided Jfrog Artifactory access token and refresh token value to Secrets Manager. 
 * - Enables Secrets manager automated rotation for provided number of days (83days).
 * - Regenrates new token using Lambda function with Jfrog API's 
 * - Sends email notification with the status of rotation (success/failed).
 *
 * **PreRequisites:** 
 * - Request for Onboarding to Jfrog Artifactory by following instructions here - [JFrog Artifactory for CI/CD Pipeline](https://wiki.comp.pge.com/pages/viewpage.action?pageId=161417454)
 * - Onboard to terraform Workspace if not already - [OnBoarding Terraform Cloud](https://wiki.comp.pge.com/display/CCE/OnBoarding+Terraform+Cloud)
 * 
 * **High Level Steps Included on this Automation:**
 * - Creation of Secrets manager credentials with provided secrets manager name and token by following PG&E standards \
 * such as encrypting credentials with custom KMS key, enabling secrets rotation and adding required tags.
 * - Creation of AWS Lambda function to generate new Jfrog token with a 90 day expiration and \
 * uploading generated token back to secrets manager. This function has been written in Python3 language.  
 * - Creation of KMS key and IAM polices as required to encrypt and access lambda & secrets manager.
 * - This automation supports storing credentials in Key/Value pair.
 *
 * For Detailed instrcutions, refer following [wiki](https://wiki.comp.pge.com/display/CCE/Jfrog+access-token+upload+to+secrets+manager+and+renewal+of+the+token+using+automation)
*/
#
#  Filename    : jfrog-token-renewal/main.tf
#  Date        : 10 Jan 2024
#  Author      : Mounika Kota
#  Description : AWS Lambda function with Environment Variables for renewing jfrog token before expiration


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  jfrog_user_name    = var.secret_string["user_name"]
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

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_caller_identity" "current" {}

#Creates new secrets manager credential and uplaods secret with automatic rotation enabled
module "secretsmanager" {
  source                     = "../../"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  # kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string           = jsonencode(var.secret_string)
  secret_version_enabled  = var.secret_version_enabled
  rotation_enabled        = var.rotation_enabled
  rotation_lambda_arn     = module.lambda_function.lambda_qualified_arn
  rotation_after_days     = var.rotation_after_days
  custom_policy           = templatefile("${path.module}/custom_policy_sm.json", { lambda_iam_role = module.aws_lambda_iam_role.arn, aws_region = var.aws_region, account_num = data.aws_caller_identity.current.account_id, secretsmanager_name = var.secretsmanager_name })

  tags = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create Lambda Function
#########################################
#lambda function which calls Jfrog api to generate new token
module "lambda_function" {
  source                      = "app.terraform.io/pgetech/lambda/aws"
  version                     = "0.1.3"
  function_name               = var.function_name
  role                        = module.aws_lambda_iam_role.arn
  description                 = var.description
  runtime                     = var.runtime
  lambda_permission_action    = "lambda:InvokeFunction"
  lambda_permission_principal = "secretsmanager.amazonaws.com"
  timeout                     = var.lambda_timeout
  publish                     = var.publish
  source_code = {
    source_dir = "${path.module}/${var.source_dir}"
  }
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
  # Provide a valid value for kms_key_arn.Invalid value gives validation error.
  environment_variables = {
    variables = {
      jfrog_secretsmanager_name = var.secretsmanager_name,
      jfrog_host                = var.jfrog_host,
      sns_topic_arn             = module.sns_topic.sns_topic_arn
      jfrog_user_name           = local.jfrog_user_name
    }
    # kms_key_arn = module.kms_key.key_arn
    kms_key_arn = null
  }
  layers = [module.lambda_layer.layer_version_arn]
}

#lambda layer for requests library with 3.11 python version.
module "lambda_layer" {
  depends_on = [ null_resource.install_python_layer ]
  
  source                                 = "app.terraform.io/pgetech/lambda/aws//modules/lambda_layer_version_local"
  version                                = "0.1.3"
  layer_version_layer_name               = join("-", [var.function_name, "lambda-layer"])
  layer_version_compatible_architectures = var.layer_version_compatible_architectures
  layer_version_compatible_runtimes      = var.layer_version_compatible_runtimes
  local_zip_source_directory             = "${path.module}/layer"
  layer_version_permission_action        = var.layer_version_permission_action
  layer_version_permission_statement_id  = var.layer_version_permission_statement_id
  layer_version_permission_principal     = var.layer_version_permission_principal
}

resource "null_resource" "install_python_layer" {
  provisioner "local-exec" {
    command = "pip3 install -r layer/requirements.txt -t layer/python"
  }
  
  # Any changes to the requirments.txt file will reprovision the lambda layer
  triggers = {
    file_hash = filemd5("${path.module}/layer/requirements.txt")
  }
}


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

#   name        = var.kms_name
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
#   policy      = templatefile("${path.module}/custom_policy_kms.json", { lambda_iam_role = module.aws_lambda_iam_role.arn })
# }


module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.lambda_sg_name
  description = var.lambda_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  # cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules = var.lambda_cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid = "1"
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]
    resources = [
      "*"
    ]
  }
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "kms-policy-jfrog-token-renewal"
  path        = "/"
  description = "Kms encrypt decrypt policy for jfrog token renewal lambda"
  policy      = [data.aws_iam_policy_document.kms_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
  policy_arns = concat(var.iam_policy_arns, [module.iam_policy.arn])
}

#########################################
# Create SNS topic
#########################################
module "sns_topic" {
  source                = "app.terraform.io/pgetech/sns/aws"
  version               = "0.1.1"
  snstopic_name         = var.snstopic_name
  snstopic_display_name = var.snstopic_display_name
  # kms_master_key_id     = module.kms_key.key_arn
  tags = merge(module.tags.tags, local.optional_tags)
}

module "sns_topic_subscription" {
  source    = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version   = "0.1.1"
  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = module.sns_topic.sns_topic_arn
}
