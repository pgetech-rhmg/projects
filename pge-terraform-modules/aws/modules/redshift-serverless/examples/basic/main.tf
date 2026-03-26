#
#  Filename    : aws/modules/redshift-serverless/examples/basic/main.tf
#  Date        : 05 Feb 2026
#  Author      : PGE
#  Description : The terraform module creates a basic Redshift Serverless setup

locals {
  optional_tags = var.optional_tags
  aws_role      = var.aws_role
  kms_role      = var.kms_role
  kms_custom_policy = templatefile("${path.module}/kms_policy.json", {
    account_num = data.aws_caller_identity.current.account_id,
    role_name   = local.aws_role
  })
  redshift_iam_policy = templatefile("${path.module}/redshift_iam_policy.json", {
    namespace_name = local.name,
    account_num    = var.account_num,
    aws_region     = var.aws_region
  })
  name  = "${var.name}-${random_string.name.result}"
  Order = var.Order
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
  name = var.parameter_vpc_id_name
}

data "aws_caller_identity" "current" {}

data "aws_subnet" "redshift_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "redshift_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "redshift_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

# KMS Key for encryption
# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# Uncomment the following lines to create the KMS key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = "alias/${local.name}"
#   description = "CMK for encrypting Redshift Serverless"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   policy      = local.kms_custom_policy
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

#The resource random_string generates a random permutation of alphanumeric characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

# Generate a secure password for the admin user
resource "random_password" "redshift_password" {
  length           = 16
  special          = true
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Security Group for Redshift Serverless using PGE security-group module
module "security_group_redshift" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 5439
    to               = 5439
    protocol         = "tcp"
    cidr_blocks      = [data.aws_subnet.redshift_1.cidr_block, data.aws_subnet.redshift_2.cidr_block, data.aws_subnet.redshift_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Redshift Serverless ingress from VPC"
  }]
  cidr_egress_rules = [{
    from             = 0
    to               = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "Allow all outbound"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

# IAM Role for Redshift Serverless using PGE IAM module
module "redshift_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  aws_service   = ["redshift.amazonaws.com"]
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [local.redshift_iam_policy]
}

# Redshift Serverless Module
module "redshift_serverless" {
  source = "../../"

  # Namespace Configuration
  namespace_name      = local.name
  admin_username      = var.admin_username
  admin_user_password = random_password.redshift_password.result
  db_name             = var.db_name
  iam_role_arns       = [module.redshift_iam_role.arn]
  # kms_key_id          = module.kms_key.key_arn  # Uncomment if using KMS
  log_exports         = var.log_exports

  # Workgroup Configuration
  workgroup_name     = "${local.name}-wg"
  base_capacity      = var.base_capacity
  max_capacity       = var.max_capacity
  subnet_ids = [
    data.aws_ssm_parameter.subnet_id1.value,
    data.aws_ssm_parameter.subnet_id2.value,
    data.aws_ssm_parameter.subnet_id3.value
  ]
  security_group_ids   = [module.security_group_redshift.sg_id]
  enhanced_vpc_routing = var.enhanced_vpc_routing
  publicly_accessible  = false

  tags = merge(module.tags.tags, local.optional_tags)
}
