/*
 * # AWS Neptune cluster snapshot with notification User module example
*/
#
#  Filename    : aws/modules/neptune/examples/cluster_snapshot_with_notification/main.tf
#  Date        : 12 July 2022
#  Author      : TCS
#  Description : The terraform module creates a cluster snapshot with notification

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
  common_name        = "${var.name}-${random_string.name.result}"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_subnet" "selected_id1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "selected_id2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "selected_id3" {
  id = data.aws_ssm_parameter.subnet_id3.value
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


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.0"
#   name        = "alias/${local.common_name}"
#   kms_role    = var.kms_role
#   description = "CMK for encrypting Neptune"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = var.aws_role
#   policy      = file("${path.module}/${var.template_file_name}")
# }


#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
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
# Create cluster snapshot with notification
#########################################

module "neptune_cluster" {
  source = "../../"

  cluster_identifier     = local.common_name
  vpc_security_group_ids = [module.security_group.sg_id]
  kms_key_arn            = null # replace with module.kms_key.key_arn, after key creation

  engine_version                       = var.engine_version
  neptune_subnet_group_name            = module.neptune_subnet_group.neptune_subnet_group_id
  neptune_cluster_parameter_group_name = module.neptune_cluster_parameter_group.neptune_cluster_parameter_group_id
  skip_final_snapshot                  = var.skip_final_snapshot
  tags                                 = merge(module.tags.tags, local.optional_tags)

  timeouts = var.timeouts
}

module "security_group" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  name        = local.common_name
  description = "Security group for example usage"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected_id1.cidr_block, data.aws_subnet.selected_id2.cidr_block, data.aws_subnet.selected_id3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected_id1.cidr_block, data.aws_subnet.selected_id2.cidr_block, data.aws_subnet.selected_id3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample egress rules"
  }]
  tags = module.tags.tags
}

module "neptune_cluster_snapshot" {
  source = "../../modules/cluster_snapshot"

  db_cluster_identifier = module.neptune_cluster.neptune_cluster_id
  #We are not using the random string resource for db_cluster_snapshot_identifier because, it will create a provider error in the terraform apply
  db_cluster_snapshot_identifier = var.name
}

module "neptune_event_subscription" {
  source = "../../modules/event_subscription"

  name          = local.common_name
  sns_topic_arn = module.sns_topic.sns_topic_arn
  neptune_source = {
    source_type = var.source_type
    #optional variable, passing null value [eventsubcription fails if snapshot as source id value is passed - snapshot creation will be still in progress due to cluster creation is not completed yet]
    source_ids = []
  }
  event_categories = var.event_categories
  tags             = merge(module.tags.tags, local.optional_tags)
}

#sns topic for event subscription
module "sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.0"

  snstopic_name         = local.common_name
  snstopic_display_name = "CloudCOE-${local.common_name}"

  #kms_key module gives error while creating neptune cluster, "unaccesible encypted credentials". 
  #Isolated issue with deny part of policy in kms module. Hence using kms_key resource to generate kms_key
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation
  tags       = merge(module.tags.tags, local.optional_tags)
}




module "neptune_cluster_parameter_group" {
  source = "../../modules/cluster_parameter_group"

  #cluster parameter group variables 
  neptune_cluster_parameter_group_name = local.common_name
  tags                                 = merge(module.tags.tags, local.optional_tags)
}

module "neptune_subnet_group" {
  source = "../../modules/subnet_group"

  neptune_subnet_group_name = local.common_name
  neptune_subnet_ids        = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags                      = merge(module.tags.tags, local.optional_tags)

}