/*
* # AWS Sagemaker module
* # Terraform module which creates aws_sagemaker_notebook_instance_lifecycle_configuration
*/
# Filename     : aws/modules/sagemaker/modules/aws_sagemaker_notebook_instance_lifecycle_configuration/main.tf 
# Date         : 21 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_sagemaker_notebook_instance_lifecycle_configuration

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "lifecycle_configuration" {
  name      = var.name
  on_create = var.on_create
  on_start  = var.on_start
}