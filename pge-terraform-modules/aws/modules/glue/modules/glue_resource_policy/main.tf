/*
*# AWS Glue resource policy module.
*Terraform module which creates SAF2.0 Glue resource policy in AWS.
*/
#
#  Filename    : aws/modules/glue/modules/glue_resource_policy/main.tf
#  Date        : 22 Auguest 2022
#  Author      : TCS
#  Description : Glue resource policy Creation


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Glue resource policy
# Description : This terraform module creates a Glue resource policy

resource "aws_glue_resource_policy" "glue_resource_policy" {

  policy        = var.glue_resource_policy
  enable_hybrid = var.glue_enable_hybrid
}