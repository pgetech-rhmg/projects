#
# Filename    : modules/utils/modules/vpcid/outputs.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the vpc id from the parameter store
#

output "vpc_id" {
  description = "vpc id"
  value       = data.aws_ssm_parameter.vpc_id.value
}
