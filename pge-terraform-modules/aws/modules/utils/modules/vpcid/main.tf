/*
 * # PG&E vpcid utils sub module
 *  Terraform module to get the vpc id from the parameter store
*/
#
# Filename    : modules/utils/modules/vpcid/main.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the vpc id from the parameter store
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

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter
}
