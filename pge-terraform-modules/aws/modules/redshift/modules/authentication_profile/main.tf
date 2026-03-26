/*
AWS Redshift module
Terraform module which creates Authentication profile
Filename     : aws/modules/redshift/modules/authentication_profile/main.tf 
Date         : 27 July 2022
Author       : TCS
Description  : Terraform sub-module for creation of Authentication profile in redshift
*/
terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

resource "aws_redshift_authentication_profile" "authentication_profile" {
  authentication_profile_name    = var.authentication_profile_name
  authentication_profile_content = var.authentication_profile_content
}