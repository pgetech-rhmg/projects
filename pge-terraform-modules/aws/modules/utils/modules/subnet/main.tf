/*
 * # PG&E subnet utils sub module
 *  Terraform module to get the subnet id or cidr from the parameter store
*/
#
# Filename    : modules/utils/modules/subnet/main.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get subnet id or cidr from the parameter store
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

data "aws_ssm_parameter" "subnet_id_cidr" {
  name = format("/vpc/privatesubnet%d/%s", var.subnet_num, (var.is_cidr ? "cidr" : "id"))
}
