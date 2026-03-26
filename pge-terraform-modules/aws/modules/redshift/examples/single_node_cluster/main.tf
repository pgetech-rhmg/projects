/*
 * # AWS Redshift
*/
#
#  Filename    : aws/modules/redshift/examples/single_node_cluster/main.tf
#  Date        : 14 July 2022
#  Author      : TCS
#  Description : The terraform module creates a single_node_cluster for redshift

locals {
  optional_tags              = var.optional_tags
  aws_role                   = var.aws_role
  kms_role                   = var.kms_role
  scheduled_actions_iam_role = templatefile("${path.module}/redshift_iam_policy.json", { cluster_identifier = var.name, account_num = var.account_num, aws_region = var.aws_region })
  kms_custom_policy          = templatefile("${path.module}/kms_policy.json", { account_num = data.aws_caller_identity.current.account_id, role_name = local.aws_role })
  name                       = "${var.name}-${random_string.name.result}"
  Order                      = var.Order
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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
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

# This section will pull the Redshift Scheduled action module
module "scheduled_action" {
  source = "../../modules/scheduled_actions"

  name               = local.name
  schedule           = var.schedule
  iam_role           = module.scheduled_actions_iam_role.arn
  cluster_identifier = module.cluster.cluster_id
  scheduled_actions = {
    pause = {
      name          = "${local.name}-${"pause"}"
      schedule      = var.pause_cluster_schedule
      pause_cluster = true
    }
    resize = {
      name     = "${local.name}-${"resize"}"
      schedule = var.resize_cluster_schedule
      resize_cluster = {
        cluster_type    = var.resize_cluster_type
        node_type       = var.resize_node_type
        number_of_nodes = var.resize_number_of_nodes
        classic         = var.classic
      }
    }
    resume = {
      name           = "${local.name}-${"resume"}"
      schedule       = var.resume_cluster_schedule
      resume_cluster = true
    }
  }
}

# This Section will pull the IAM role module needed for the 'Assume Role' variable for scheduled actions
module "scheduled_actions_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy for the 'Assume Role' to run scheduled actions
  inline_policy = [local.scheduled_actions_iam_role]
}

# This section will pull the Redshift cluster module
module "cluster" {
  source = "../../"

  cluster_identifier           = local.name
  master_password              = random_password.redshift_password.result
  master_username              = "aws${random_string.name.result}"
  node_type                    = var.node_type
  cluster_type                 = var.cluster_type
  cluster_subnet_group_name    = module.redshift_subnet_group.redshift_subnet_group_id
  skip_final_snapshot          = var.skip_final_snapshot
  vpc_security_group_ids       = [module.security_group_redshift.sg_id]
  cluster_parameter_group_name = module.parameter_group.parameter_group_id
  s3_key_prefix                = var.s3_key_prefix
  kms_key_id                   = null # replace with module.kms_key.key_arn, after key creation
  tags                         = merge(module.tags.tags, local.optional_tags)
}





module "redshift_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = "custom-${local.name}"
  aws_service   = var.cluster_role_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [file("${path.module}/redshift_iam_policy_default.json")]
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