/*
* # AWS Sagemaker module
* # Terraform module which creates model_package_group_policy
*/
# Filename     : aws/modules/sagemaker/modules/model_package_group_policy/main.tf 
# Date         : 02 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of model_package_group_policy

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

resource "aws_sagemaker_model_package_group_policy" "model_package_group_policy" {
  model_package_group_name = var.model_package_group_name
  resource_policy          = var.model_package_group_resource_policy
}