/*
* # AWS AppStream2.0 fleet_stack_association module
* Terraform module which creates fleet_stack_association for AppStream2.0 
*/
#Filename     : aws/modules/appstream2/modules/fleet_stack_association/main.tf 
#Date         : 19 Aug 2022
#Author       : TCS
#Description  : Terraform module for creation of fleet_stack_association

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_appstream_fleet_stack_association" "fleet_stack" {
  fleet_name = var.fleet_name
  stack_name = var.stack_name
}