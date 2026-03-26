/*
 * # AWS Sagemaker domain service example
 * # The terraform usage example creates Sagemaker domain service
 * # Only 1 sagemaker domain can be created in an account/region, for more info 'https://docs.aws.amazon.com/general/latest/gr/sagemaker.html#limits_sagemaker'
*/
#  Filename    : aws/modules/sagemaker/examples/domain/main.tf
#  Date        : 15 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates domain

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


data "aws_subnet" "domain_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "domain_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "domain_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "domain" {
  source = "../../modules/domain"

  domain_name     = local.name
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  subnet_ids      = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  execution_role  = module.domain_iam_role.arn
  security_groups = [module.security_group.sg_id]
  kms_key_id      = null # replace with module.domain_kms.key_arn, after key creation 
  tags            = merge(module.tags.tags, var.optional_tags)
  #Sharing Settings
  notebook_output_option = var.notebook_output_option
  s3_output_path         = "s3://${local.name}/sagemaker"
  #Jupyter Server App Settings
  jupyter_server_app_settings_instance_type         = var.jupyter_server_app_settings_instance_type
  jupyter_server_app_settings_lifecycle_config_arn  = var.jupyter_server_app_settings_lifecycle_config_arn
  jupyter_server_app_settings_lifecycle_config_arns = var.jupyter_server_app_settings_lifecycle_config_arns
  #Retention Policy
  home_efs_file_system = var.home_efs_file_system
  #TensorBoard App Settings
  tensor_board_app_settings_instance_type        = var.tensor_board_app_settings_instance_type
  tensor_board_app_settings_lifecycle_config_arn = var.tensor_board_app_settings_lifecycle_config_arn
  #Kernel Gateway App Settings
  kernel_gateway_app_settings_instance_type         = var.kernel_gateway_app_settings_instance_type
  kernel_gateway_app_settings_lifecycle_config_arn  = var.kernel_gateway_app_settings_lifecycle_config_arn
  kernel_gateway_app_settings_lifecycle_config_arns = var.kernel_gateway_app_settings_lifecycle_config_arns

  # Default Space Settings - Controls default settings for SageMaker Studio Spaces
  default_space_execution_role                            = var.default_space_execution_role
  default_space_security_groups                           = var.default_space_security_groups
  default_space_jupyter_server_app_settings_instance_type = var.default_space_jupyter_server_app_settings_instance_type
  default_space_kernel_gateway_app_settings_instance_type = var.default_space_kernel_gateway_app_settings_instance_type

  # Custom Tag Propagation
  tag_propagation = var.tag_propagation
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
    cidr_blocks      = [data.aws_subnet.domain_1.cidr_block, data.aws_subnet.domain_2.cidr_block, data.aws_subnet.domain_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.domain_1.cidr_block, data.aws_subnet.domain_2.cidr_block, data.aws_subnet.domain_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

module "domain_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = "custom-${local.name}"
  aws_service   = var.domain_role_service
  tags          = merge(module.tags.tags, var.optional_tags)
  inline_policy = [file("${path.module}/domain_iam_policy.json")]
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "domain_kms" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1.0"

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}