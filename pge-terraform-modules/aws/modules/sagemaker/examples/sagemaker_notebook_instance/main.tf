/*
 * # AWS Sagemaker
*/
#
#  Filename    : aws/modules/sagemaker/examples/sagemaker_notebook_instance/main.tf
#  Author      : TCS
#  Description : The terraform module creates a sagemaker_notebook_instance for Sagemaker

locals {
  optional_tags = var.optional_tags
  aws_role      = var.aws_role
  name          = "${var.name}-${random_string.name.result}"
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

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length           = 8
  special          = true
  override_special = "-"
}

#Supporting Resource
data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
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


data "aws_subnet" "sagemaker_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "sagemaker_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "sagemaker_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

module "notebook_instance" {
  source = "../../modules/notebook_instance"

  instance_name            = local.name
  role_arn                 = module.sagemaker_iam_role.arn
  instance_type            = var.instance_type
  platform_identifier      = var.platform_identifier
  volume_size              = var.volume_size
  direct_internet_access   = var.direct_internet_access
  root_access              = var.root_access
  security_groups          = [module.security_group_sagemaker.sg_id]
  subnet_id                = data.aws_ssm_parameter.subnet_id1.value
  kms_key_id               = null # replace with module.kms_key.key_arn, after key creation 
  default_code_repository  = aws_sagemaker_code_repository.example.id
  lifecycle_config_name    = var.lifecycle_config_name
  metadata_service_version = var.metadata_service_version

  tags = merge(module.tags.tags, local.optional_tags)
}

module "sagemaker_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = local.name
  aws_service   = var.role_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [file("${path.module}/sagemaker_iam_policy.json")]
}

module "security_group_sagemaker" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.sagemaker_1.cidr_block, data.aws_subnet.sagemaker_2.cidr_block, data.aws_subnet.sagemaker_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.sagemaker_1.cidr_block, data.aws_subnet.sagemaker_2.cidr_block, data.aws_subnet.sagemaker_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "kms_key" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1.0"

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}

#To test code repository
resource "aws_sagemaker_code_repository" "example" {
  code_repository_name = "example"

  git_config {
    repository_url = "https://github.com/hashicorp/terraform-provider-aws.git"
  }
}

