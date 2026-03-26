#
# Filename    : modules/utils/modules/subnet/outputs.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get a generic parameter from the parameter store, default appid
#

output "value" {
  description = "value of parameter store variable requested"
  value       = data.aws_ssm_parameter.ssm.value
}
