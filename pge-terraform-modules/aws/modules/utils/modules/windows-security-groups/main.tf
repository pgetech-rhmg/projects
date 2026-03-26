/*
 * # PG&E windows-security-groups utils sub module
 *  Terraform module to get PGE windows security group ids from the parameter store
*/
#
# Filename    : modules/utils/modules/windows-security-groups/main.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the security group id's as list for use with PGE windows ec2
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_ssm_parameter" "windows_ad_golden" {
  name = "/ec2/windows/security_group_id/ad"
}

data "aws_ssm_parameter" "windows_bmc_proxy_golden" {
  name = "/ec2/windows/security_group_id/bmc_proxy"
}

data "aws_ssm_parameter" "windows_bmc_scanner_golden" {
  name = "/ec2/windows/security_group_id/bmc_scanner"
}

data "aws_ssm_parameter" "windows_encase_golden" {
  name = "/ec2/windows/security_group_id/encase"
}

data "aws_ssm_parameter" "windows_rdp_golden" {
  name = "/ec2/windows/security_group_id/rdp"
}

data "aws_ssm_parameter" "windows_sccm_golden" {
  name = "/ec2/windows/security_group_id/sccm"
}

data "aws_ssm_parameter" "windows_scom_golden" {
  name = "/ec2/windows/security_group_id/scom"
}
