/*
 * # AWS EC2 module example
*/
#  Filename    : aws/modules/ec2/examples/pge_linux
#  Date        : 7 Feb 2023
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : PGE linux ec2 instance creation using ec2 module. EBS will be be encrypted with CMEK. RootBlock Device can be encrypted with AWS managed or CMEK.
#  KMS_KEY_ID is mandatory if the DataClassification is not "Internal".

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  name               = var.Name
  InstanceType       = var.InstanceType
  kms_role           = var.kms_role
  aws_role           = var.aws_role
  AvailabilityZone   = var.AvailabilityZone
  user_data          = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  EOT
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/2/privatesubnet1/id"
}

data "aws_ssm_parameter" "golden_ami" {
  name = "/ami/linux/golden"
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }
#########################################
# Create Standalone Security Group
#########################################

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = local.name
  description        = "Security group for example usage with EC2 instance"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = module.tags.tags
}


################################################################################
# Create EC2 Module
################################################################################
module "ec2" {
  source                 = "../../"
  name                   = local.name
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = local.InstanceType
  availability_zone      = local.AvailabilityZone
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.security_group.sg_id]
  user_data_base64       = base64encode(local.user_data)
  metadata_http_endpoint = var.metadata_http_endpoint
  instance_profile_role  = var.instance_profile_role

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      kms_key_id  = null # replace with module.kms_key.key_arn, after key creation
      tags = {
        Name = "pge-terraform-module-example"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      kms_key_id  = null # replace with module.kms_key.key_arn, after key creation
    }
  ]

  tags = merge(module.tags.tags, local.optional_tags)
}
