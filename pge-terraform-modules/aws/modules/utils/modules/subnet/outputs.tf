#
# Filename    : modules/utils/modules/subnet/outputs.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get subnet id or cidr from the parameter store
#

output "subnet_id_cidr" {
  description = "subnet id or cidr"
  value       = data.aws_ssm_parameter.subnet_id_cidr.value
}
