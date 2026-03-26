data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  vpc             = var.partner == "MRAD" ? "${var.partner}-${var.aws_account}-VPC" : var.vpc
  private_subnet1 = var.partner == "MRAD" ? "${var.partner}-${var.aws_account}-PrivateSubnet1" : var.subnet1
  private_subnet2 = var.partner == "MRAD" ? "${var.partner}-${var.aws_account}-PrivateSubnet2" : var.subnet2
  private_subnet3 = var.partner == "MRAD" ? "${var.partner}-${var.aws_account}-PrivateSubnet3" : var.subnet3
}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc]
  }
}

data "aws_subnet" "private1" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet1]
  }
}

data "aws_subnet" "private2" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet2]
  }
}

data "aws_subnet" "private3" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet3]
  }
}
