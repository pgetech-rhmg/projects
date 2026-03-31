###############################################################################
# Data Sources
###############################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# VPC and networking from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/privatesubnet2/id"
}

data "aws_ssm_parameter" "subnet_id3" {
  name = "/vpc/privatesubnet3/id"
}

data "aws_vpc" "vpc" {
  id = data.aws_ssm_parameter.vpc_id.value
}

# Enterprise KMS key
data "aws_ssm_parameter" "enterprise_kms" {
  name = "/enterprise/kms/keyarn"
}

locals {
  subnet_ids = [
    data.aws_ssm_parameter.subnet_id1.value,
    data.aws_ssm_parameter.subnet_id2.value,
    data.aws_ssm_parameter.subnet_id3.value,
  ]

  builder_subnet_id = local.subnet_ids[var.subnet_index - 1]
}
