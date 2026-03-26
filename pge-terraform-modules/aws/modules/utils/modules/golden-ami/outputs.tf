#
# Filename    : modules/utils/modules/golden-ami/outputs.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the golden ami id from the parameter store
#

output "ami_id" {
  description = "AMI id"
  value       = data.aws_ssm_parameter.ami_id.value
}
