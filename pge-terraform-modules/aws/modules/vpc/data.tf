data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "parameter_transit_gateway" {
  name = var.parameter_transit_gateway
}