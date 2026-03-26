/*
 * # AWS EC2 Image Builder Module
 * Terraform module which creates and manages AWS EC2 Image Builder resources such as image pipelines, recipes, and infrastructure configurations.
*/
#
#  Filename    : modules/imagebuilder/main.tf
#  Date        : 3 Oct 2024
#  Author      : PGE
#  Description : Automates AMI creation with Image Builder, ensuring compliance with encryption and security policies.
#

terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Security Group
# ---------------------------------------------------------------------------------------------------------------------
module "image_builder_sg" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"
  name    = "${var.name}-sg"
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  # Ingress rule for HTTPS access
  cidr_ingress_rules = [
    {
      description      = "Allow HTTPS access"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = [data.aws_ssm_parameter.vpc_cidr.value]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  # Egress rule allowing all outbound traffic
  cidr_egress_rules = [{
    description      = "Allow all outbound"
    from             = 0
    to               = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }]

  tags = local.module_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Role
# ---------------------------------------------------------------------------------------------------------------------
# Policy document to allow the ec2 instance to assume necessary roles 
data "aws_iam_policy_document" "assume_role_document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "kms_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "kms:Decrypt", "kms:GenerateDataKey", "kms:CreateGrant", "kms:DescribeKey", "ec2:CreateTags"]
    resources = ["*"]
  }
}

# IAM role for Imagebuilder instance allowing SSM agent and necessary permissions
module "imagebuilder_instance_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.name}-instance-role"
  aws_service   = ["ec2.amazonaws.com"]
  tags          = var.tags
  inline_policy = [data.aws_iam_policy_document.assume_role_document.json]
  policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", module.custom_kms_secrets_policy.arn, module.imagebuilder_get_component_policy.arn, "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

# IAM role for Imagebuilder service allowing the full access 
module "imagebuilder_service_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.name}-service-role"
  aws_service   = ["imagebuilder.amazonaws.com"]
  tags          = local.module_tags
  inline_policy = [data.aws_iam_policy_document.assume_role_document.json, data.aws_iam_policy_document.sns_policy_document.json]
  policy_arns   = ["arn:aws:iam::aws:policy/AWSImageBuilderFullAccess"]
}

module "custom_kms_secrets_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"
  name    = "${var.name}-custom-kms-secret-policy"
  policy  = [data.aws_iam_policy_document.kms_policy_document.json]
  tags    = local.module_tags
}

# Imagebuilder instance profile
resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.name}-instance-profile"
  role = module.imagebuilder_instance_role.name
  tags = local.module_tags
}

data "aws_iam_policy_document" "get_component_policy_document" {
  statement {
    effect = "Allow"
    actions = ["imagebuilder:GetComponent",
      "imagebuilder:ListComponents",
      "ssm:Get*",
      "sns:*",
    "imagebuilder:GetComponentVersion"]
    resources = ["*"]
  }
}

module "imagebuilder_get_component_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"
  name    = "${var.name}-get-component-policy"
  policy  = [data.aws_iam_policy_document.get_component_policy_document.json]
  tags    = local.module_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Image Builder Infrastructure Configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_imagebuilder_infrastructure_configuration" "imagebuilder_infra_config" {
  count                 = 1
  instance_profile_name = aws_iam_instance_profile.iam_instance_profile.name
  instance_types        = var.ec2_imagebuilder_instance_types
  key_pair              = var.instance_key_pair

  name               = "${var.name}-infra-config"
  security_group_ids = var.create_security_group ? [module.image_builder_sg.sg_id] : var.security_group_ids
  # subnet_id          = var.subnet_id
  subnet_id = data.aws_ssm_parameter.subnet_id_az_c.value

  instance_metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  terminate_instance_on_failure = var.terminate_instance_on_failure
  resource_tags                 = local.module_tags
  tags                          = local.module_tags

  logging {
    s3_logs {
      s3_bucket_name = var.s3_bucket_name
      s3_key_prefix  = "logs"
    }
  }

  sns_topic_arn = module.imagebuilder_sns_topic.sns_topic_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Image Builder Image
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_imagebuilder_image" "image_builder_img" {
  count                            = 1
  image_recipe_arn                 = aws_imagebuilder_image_recipe.image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.imagebuilder_infra_config[count.index].arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.without_license[0].arn
  enhanced_image_metadata_enabled  = var.enhanced_image_metadata_enabled
  execution_role                   = var.execution_role

  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
    timeout_minutes     = var.timeout_minutes
  }

  tags = local.module_tags

  timeouts {
    create = var.timeout
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Image Builder Image Pipeline
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_imagebuilder_image_pipeline" "imagebuilder_pipeline" {
  count                            = 1
  image_recipe_arn                 = aws_imagebuilder_image_recipe.image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.imagebuilder_infra_config[count.index].arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.without_license[0].arn
  status                           = var.pipeline_status
  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
  }

  dynamic "schedule" {
    for_each = try(var.schedule_expression, tomap({}))
    content {
      schedule_expression                = schedule.key
      pipeline_execution_start_condition = schedule.value
    }
  }
  name = "${var.name}-pipeline"
  tags = local.module_tags
}
# EC2 Image Builder Component
module "imagebuilder_component" {
  source                = "./modules/imagebuilder_component"
  component_name_prefix = var.name
  component_version     = var.component_version
  component_platform    = var.component_platform
  component_data        = var.component_data
  tags                  = local.module_tags

}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Image Builder Image Recipe
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "parent_image" {

  name = var.parent_image_ssm_path
}
locals {
  updated_component = concat(
    module.imagebuilder_component.component_arns,
    var.aws_owned_component_arn
  )
}
resource "aws_imagebuilder_image_recipe" "image_recipe" {
  name              = "${var.name}-image-recipe"
  version           = var.recipe_version
  parent_image      = data.aws_ssm_parameter.parent_image.value
  description       = var.recipe_description
  user_data_base64  = var.user_data_base64
  working_directory = var.working_directory

  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.recipe_volume_size
      volume_type           = var.recipe_volume_type
      delete_on_termination = var.delete_on_termination_img_recipe
      iops                  = var.block_device_iops
      throughput            = var.block_device_throughput
    }
  }
  dynamic "component" {
    for_each = local.updated_component
    content {
      component_arn = component.value
    }
  }
  # component {
  #   component_arn = module.imagebuilder_component.component_arn
  # }
  systems_manager_agent {
    uninstall_after_build = var.uninstall_after_build
  }

  tags = local.module_tags
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Image Builder Distribution Configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_imagebuilder_distribution_configuration" "with_license" {
  count       = length(var.license_configuration_arn) > 0 ? 1 : 0
  name        = "${var.name}-with-license"
  description = "Distribution configuration with license"
  distribution {
    region = var.aws_region
    ami_distribution_configuration {
      name        = "${var.name}-{{ imagebuilder:buildVersion }}-{{ imagebuilder:buildDate }}-with-license"
      description = ""
    }
    license_configuration_arns = [var.license_configuration_arn]
  }
  tags = local.module_tags



}
resource "aws_imagebuilder_distribution_configuration" "without_license" {
  count       = length(var.license_configuration_arn) == 0 ? 1 : 0
  name        = "${var.name}-without-license"
  description = "Destribution configuration without license"
  distribution {
    region = var.aws_region
    ami_distribution_configuration {
      name        = "${var.name}-{{ imagebuilder:buildVersion }}-{{ imagebuilder:buildDate }}-without-license"
      description = ""
    }
  }
  tags = local.module_tags


}

module "imagebuilder_sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.1"

  snstopic_name         = "${var.name}-imagebuilder-notification"
  snstopic_display_name = "${var.name}-imagebuilder-notification"
  kms_key_id            = null # replace with module.kms_key.key_arn, after key creation
  tags                  = var.tags
}


module "email_sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.1"

  snstopic_name         = "${var.name}-email-notification"
  snstopic_display_name = "${var.name}-email-notification"
  kms_key_id            = null # replace with module.kms_key.key_arn, after key creation
  tags                  = var.tags
}

module "sns_topic_subscription" {
  # for_each = toset(var.notification_email)
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = toset(var.notification_email)
  protocol  = "email"
  topic_arn = module.email_sns_topic.sns_topic_arn
}

data "aws_iam_policy_document" "sns_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [module.imagebuilder_sns_topic.sns_topic_arn]
  }
}
module "sns_message_processor" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = "${var.name}-sns-message-processor"
  role          = module.aws_lambda_iam_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 256

  source_code = {
    source_dir = "${path.module}/src"
  }
  environment_variables = {
    variables = {
      AMI_ID_PARAM      = data.aws_ssm_parameter.ami_parameter.name
      BETA_AMI_ID_PARAM = data.aws_ssm_parameter.beta_ami_parameter.name
      AMI_STATUS_PARAM  = data.aws_ssm_parameter.status_ami_parameter.name
      SNS_TOPIC_ARN     = module.email_sns_topic.sns_topic_arn
      ACCOUNT_IDS       = join(",", var.launch_permission_user_ids)
      RECEIPIENTS       = join(",", var.receipients)
      SENDER            = var.sender
      SSM_DOCUMENT_NAME_NONPROD = aws_ssm_document.automation_document.name
      SSM_DOCUMENT_NAME_PROD = aws_ssm_document.automation_document_prod.name
      ENVIRONMENT = var.tags["Environment"]
    }
    kms_key_arn = data.aws_ssm_parameter.cmk_arn.value
  }
  vpc_config_security_group_ids = [module.lambda_security_group.sg_id]
  vpc_config_subnet_ids = [data.aws_ssm_parameter.subnet_id_az_a.value,
    data.aws_ssm_parameter.subnet_id_az_b.value,
  data.aws_ssm_parameter.subnet_id_az_c.value]
  tags = var.tags
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.name}-sns-message-processor"
  principal     = "sns.amazonaws.com"
  source_arn    = module.imagebuilder_sns_topic.sns_topic_arn
  depends_on    = [module.sns_message_processor]
}


module "sns_topic_subscription_imagebuilder" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = [module.sns_message_processor.lambda_arn]
  protocol  = "lambda"
  topic_arn = module.imagebuilder_sns_topic.sns_topic_arn
}


module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.name}-sns-lambda-role"
  aws_service = ["lambda.amazonaws.com"]
  tags        = var.tags

}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    #DynamoDB permissions
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    # SES Permissions
    actions = [

      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter"
    ]
    resources = [

      "arn:aws:ssm:${var.aws_region}:${var.account_num}:parameter/ami-builder/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Receive",
      "sns:Subscribe"
    ]
    resources = [

      module.email_sns_topic.sns_topic_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [

      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:ModifyImageAttribute",
      "ec2:Describe*",
      "ec2:*",
      "ssm:*",
      "kms:*"


    ]
    resources = [

      "*"
    ]

  }
}
module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name   = "${var.name}-lambda-policy"
  path   = "/"
  policy = [data.aws_iam_policy_document.lambda_policy.json]

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = module.aws_lambda_iam_role.name
  policy_arn = module.iam_policy.arn
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}



