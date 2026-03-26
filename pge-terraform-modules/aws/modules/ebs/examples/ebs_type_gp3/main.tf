/*
 * # AWS EBS ebs_type_gp3 module example
*/
#
#  Filename    : modules/ebs/examples/ebs_type_gp3/main.tf
#  Date        : 25 Jan 2022
#  Author      : TCS
#  Description : creation of ebs volume of gp3 type
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Optional_tags      = var.Optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

#   name        = var.kms_name
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.Optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

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

data "aws_ssm_parameter" "golden_ami" {
  name = var.golden_ami_name
}

#########################################
# Create ebs
########################################

module "ebs" {
  source            = "../../"
  availability_zone = var.ebs_availability_zone
  size              = var.ebs_size
  type              = var.ebs_type
  kms_key_id        = null # replace with module.kms_key.key_arn, after key creation
  instance_id       = [module.ec2.id]
  device_name       = var.ebs_device_name
  tags              = merge(module.tags.tags, local.Optional_tags)
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.Optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.security_group.sg_id]

  tags = merge(module.tags.tags, local.Optional_tags)
}