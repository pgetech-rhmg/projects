/*
 * # AWS Sagemaker user_profile example
 * # Usage example for Sagemaker user_profile
*/
#  Filename    : aws/modules/sagemaker/examples/user_profile/main.tf
#  Date        : 19 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates user_profile in sagemaker domain

locals {
  name = "${var.name}-${random_string.name.result}"
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
  Order              = var.Order
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


data "aws_subnet" "user_profile_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "user_profile_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "user_profile_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "user_profile" {
  source = "../../modules/user_profile"

  user_profile_name = local.name
  domain_id         = var.domain_id
  execution_role    = module.user_profile_iam_role.arn
  security_groups   = [module.security_group.sg_id]
  tags              = merge(module.tags.tags, var.optional_tags)
  #Sharing Settings
  notebook_output_option = var.notebook_output_option
  s3_kms_key_id          = null # replace with module.user_profile_kms.key_arn, after key creation 
  s3_output_path         = "s3://${local.name}/sagemaker"
  #Jupyter Server App Settings
  jupyter_server_app_settings_instance_type         = var.jupyter_server_app_settings_instance_type
  jupyter_server_app_settings_lifecycle_config_arn  = module.studio_lifecycle_config.studio_lifecycle_config_arn
  jupyter_server_app_settings_lifecycle_config_arns = [module.studio_lifecycle_config.studio_lifecycle_config_arn]
  #TensorBoard App Settings
  tensor_board_app_settings_instance_type        = var.tensor_board_app_settings_instance_type
  tensor_board_app_settings_lifecycle_config_arn = module.studio_lifecycle_config.studio_lifecycle_config_arn
  #Kernel Gateway App Settings
  kernel_gateway_app_settings_instance_type         = var.kernel_gateway_app_settings_instance_type
  kernel_gateway_app_settings_lifecycle_config_arn  = module.studio_lifecycle_config.studio_lifecycle_config_arn
  kernel_gateway_app_settings_lifecycle_config_arns = [module.studio_lifecycle_config.studio_lifecycle_config_arn]
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.user_profile_1.cidr_block, data.aws_subnet.user_profile_2.cidr_block, data.aws_subnet.user_profile_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.user_profile_1.cidr_block, data.aws_subnet.user_profile_2.cidr_block, data.aws_subnet.user_profile_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "user_profile_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = "custom-${local.name}"
  aws_service   = var.user_profile_role_service
  tags          = merge(module.tags.tags, var.optional_tags)
  inline_policy = [file("${path.module}/user_profile_iam_policy.json")]
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "user_profile_kms" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1.2"

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}

module "studio_lifecycle_config" {
  source = "../../modules/studio_lifecycle_config"

  studio_lifecycle_config_name     = local.name
  studio_lifecycle_config_app_type = var.studio_lifecycle_config_app_type
  studio_lifecycle_config_content  = base64encode(file("${path.module}/${var.studio_lifecycle_config_content}"))
  tags                             = merge(module.tags.tags, var.optional_tags)
}