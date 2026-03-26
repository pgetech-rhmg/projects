/*
 * # PG&E golden-ami utils sub module
 *  Terraform module to get the golden ami from the parameter store
*/
#
# Filename    : modules/utils/modules/golden-ami/main.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the golden ami id from the parameter store
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

data "aws_ssm_parameter" "ami_id" {
  name = var.parameter == null ? (var.os == "linux" ? "/ami/linux/golden" : "/ami/base-windows-2019/latest") : var.parameter
}
