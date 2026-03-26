#
# Filename    : modules/utils/modules/windows-security-groups/outputs.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the security group id's as list for use with PGE windows ec2
#

output "win_sg_list" {
  description = "PGE windows security group list"
  value       = [data.aws_ssm_parameter.windows_sccm_golden.value, data.aws_ssm_parameter.windows_encase_golden.value, data.aws_ssm_parameter.windows_rdp_golden.value, data.aws_ssm_parameter.windows_ad_golden.value, data.aws_ssm_parameter.windows_bmc_scanner_golden.value, data.aws_ssm_parameter.windows_bmc_proxy_golden.value, data.aws_ssm_parameter.windows_scom_golden.value]
}
