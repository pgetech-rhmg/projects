#
# Filename    : modules/rds/examples/rds_vpc_endpoint/main.tf
# Date        : 6 January 2022
# Author      : TCS
# Description : The Terraform Module creates RDS VPC Endpoint

############################
# Creates an RDS VPC Endpoint
#########################################
data "aws_ssm_parameter" "private_subnet1_id" {
  name = "/vpc/2/privatesubnet1/id"
}
data "aws_ssm_parameter" "private_subnet2_id" {
  name = "/vpc/2/privatesubnet2/id"
}
data "aws_ssm_parameter" "private_subnet3_id" {
  name = "/vpc/2/privatesubnet3/id"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}


module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.sg_name
  description        = "Security group for example usage with VPC Endpoint"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(var.tags, var.optional_tags)
}

module "rds_vpc_endpoint_interface" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  service_name       = var.service_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]
  security_group_ids = [module.security_group.sg_id]
  tags               = merge(var.tags, var.optional_tags)
}
