data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.subnet_id3_name
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_security_group" "default" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  name   = "default"
}