/*
 * # AWS Redshift
*/
#
#  Filename    : aws/modules/redshift/examples/multi_node_cluster/main.tf
#  Date        : 14 July 2022
#  Author      : TCS
#  Description : The terraform module creates a multi_node_cluster for redshift

locals {
  optional_tags     = var.optional_tags
  new_template_var  = templatefile("${path.module}/${var.authentication_profile_content}", { AllowDBUserOverride = var.AllowDBUserOverride, Client_ID = var.Client_ID, App_ID = var.App_ID })
  aws_role          = var.aws_role
  kms_role          = var.kms_role
  kms_custom_policy = templatefile("${path.module}/kms_policy.json", { account_num = data.aws_caller_identity.current.account_id, role_name = local.aws_role })
  name              = "${var.name}-${random_string.name.result}"
  Order             = var.Order
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


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = "alias/${local.name}"
#   description = "CMK for encrypting Redshift"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   policy      = local.kms_custom_policy
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }


#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

resource "random_password" "redshift_password" {
  length           = 16
  special          = true
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "parameter_group" {
  source = "../../modules/parameter_group"

  name = local.name
  tags = merge(module.tags.tags, local.optional_tags)
}

# This section will pull the Redshift Subnet_group module
module "redshift_subnet_group" {
  source = "../../modules/subnet_group"

  subnet_group_name = local.name
  subnet_ids        = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags              = merge(module.tags.tags, local.optional_tags)
}

# Endpoint_access module
module "endpoint_access" {
  source = "../../modules/endpoint_access"

  name               = local.name
  subnet_group_name  = module.redshift_subnet_group.redshift_subnet_group_id
  cluster_identifier = module.cluster.cluster_id
}

# This section will pull the authentication_profile module
#AWS console does not have an option to check for authentication profile, so we need to check with AWS CLI 
#Command to check all the available authentication profiles through CLI is 'aws redshift describe-authentication-profiles'
module "authentication_profile" {
  source = "../../modules/authentication_profile"

  authentication_profile_name    = local.name
  authentication_profile_content = local.new_template_var
}

# This section will pull the usage limit module
module "usage_limit" {
  source = "../../modules/usage_limit"

  cluster_identifier = module.cluster.cluster_id
  breach_action      = var.breach_action
  amount             = var.amount
  period             = var.period
  validate_feature_limit = {
    feature_type = "concurrency-scaling"
    limit_type   = "time"
  }
  tags = merge(module.tags.tags, local.optional_tags)
}

# This section will pull the Redshift cluster module
module "cluster" {
  source = "../../"

  cluster_identifier        = local.name
  master_password           = random_password.redshift_password.result
  master_username           = "aws${random_string.name.result}"
  node_type                 = var.node_type
  cluster_type              = var.cluster_type
  number_of_nodes           = var.number_of_nodes
  cluster_subnet_group_name = module.redshift_subnet_group.redshift_subnet_group_id
  skip_final_snapshot       = var.skip_final_snapshot
  redshift_availability_zone = {
    availability_zone_relocation_enabled = var.availability_zone_relocation_enabled
    availability_zone                    = var.availability_zone
  }
  cluster_parameter_group_name = module.parameter_group.parameter_group_id
  vpc_security_group_ids       = [module.security_group_redshift.sg_id]
  s3_key_prefix                = var.s3_key_prefix
  kms_key_id                   = null # replace with module.kms_key.key_arn, after key creation
  tags                         = merge(module.tags.tags, local.optional_tags)
}


module "redshift_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  aws_service   = var.cluster_role_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [file("${path.module}/redshift_iam_policy.json")]
}

module "security_group_redshift" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.redshift_1.cidr_block, data.aws_subnet.redshift_2.cidr_block, data.aws_subnet.redshift_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.redshift_1.cidr_block, data.aws_subnet.redshift_2.cidr_block, data.aws_subnet.redshift_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

#Time sleep is used to wait for 05 mins after cluster resource creation,this is needed for the cluster to succesfully initialize 
resource "time_sleep" "wait" {
  depends_on      = [module.cluster]
  create_duration = var.create_duration
}

module "cluster_roles" {
  depends_on = [time_sleep.wait]
  source     = "../../modules/cluster_iam_roles"

  cluster_identifier = module.cluster.cluster_cluster_identifier
  iam_role_arns      = [module.redshift_iam_role.arn]
}