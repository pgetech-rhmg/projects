data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.subnet_id3_name
}

data "aws_subnet" "subnet1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "subnet2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "subnet3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}
