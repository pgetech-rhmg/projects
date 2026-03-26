#
# Filename    : modules/efs/examples/efs_ec2_mount/main.tf
# Date        : 2 february 2022
# Author      : TCS
# Description : Efs usage to mount efs to ec2

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
  user_data          = <<-EOT
#!/bin/bash
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
yum install -y amazon-efs-utils
if [[ -d "/mnt/efs" ]]
then
  echo "Directory already /mnt/efs exists"
else
  mkdir /mnt/efs
  echo "created directory"
fi
echo "${module.efs.efs_id}:/ /mnt/efs efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
mount -fav
  EOT
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

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

data "aws_ssm_parameter" "golden_ami" {
  name = var.golden_ami_name
}
# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags            = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }
#########################################
# Create efs file system
#########################################
module "efs" {
  source = "../../"

  kms_key_id      = null # replace with module.kms_key.key_arn, after key creation
  subnet_id       = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  security_groups = [module.security_group.sg_id]
  tags            = merge(module.tags.tags, local.optional_tags)
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.0"

  name                   = var.ec2_name
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  availability_zone      = var.ec2_az
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.security_group.sg_id]

  user_data_base64 = base64encode(local.user_data)


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = var.root_block_device_volume_type
      kms_key_id  = null # replace with module.kms_key.key_arn, after key creation
      throughput  = var.root_block_device_throughput
      volume_size = var.root_block_device_volume_size
      tags        = merge(module.tags.tags, { Name = "my-root-block" })
    }
  ]

  tags = merge(module.tags.tags, local.optional_tags)
}
