
/*
 * # AWS SSM state manager association for patch managment
 * Terraform module which creates SAF2.0 SSM State Manager Association in AWS
*/
#
#  Filename    : aws/modules/ssm/examples/state-manager-association/data.tf
#  Date        : 08 August 2022
#  Author      : PGE
#  Description : creation of SSM state manager association module
#

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}



