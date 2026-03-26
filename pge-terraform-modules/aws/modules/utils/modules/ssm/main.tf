/*
 * # PG&E ssm utils sub module
 *  Terraform module to get a generic parameter from the parameter store
*/
#
# Filename    : modules/utils/modules/subnet/main.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get a generic parameter from the parameter store, default appid
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

data "aws_ssm_parameter" "ssm" {
  name = var.name
}
