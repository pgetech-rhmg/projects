data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.parameter_subnet_id3_name
}
