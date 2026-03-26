/*
* # AWS Sagemaker module
* # Terraform module which creates image_version
*/
# Filename     : aws/modules/sagemaker/modules/image_version/main.tf 
# Date         : 7 september 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of image_version

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

resource "aws_sagemaker_image_version" "image_version" {
  image_name = var.image_name
  base_image = var.base_image
}
