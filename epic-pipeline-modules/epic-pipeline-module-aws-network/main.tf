############################################
# Existing VPC (SAF 2.0 Managed)
############################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_vpc_id_parameter
}

############################################
# Existing Private Subnets
############################################

data "aws_ssm_parameter" "subnet_a" {
  name = var.ssm_private_subnet_a_parameter
}

data "aws_ssm_parameter" "subnet_b" {
  name = var.ssm_private_subnet_b_parameter
}

############################################
# Outputs
############################################

locals {
  private_subnet_ids = [
    data.aws_ssm_parameter.subnet_a.value,
    data.aws_ssm_parameter.subnet_b.value
  ]
}

