/*
 * # AWS Redshift
 * Terraform module which creates SAF2.0 Redshift endpoint_access in AWS
*/
#  Filename    : aws/modules/redshift/modules/endpoint_access/main.tf
#  Description : The terraform module creates a endpoint_access for redshift cluster

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_redshift_endpoint_access" "endpoint" {
  endpoint_name          = var.name
  subnet_group_name      = var.subnet_group_name
  cluster_identifier     = var.cluster_identifier
  vpc_security_group_ids = var.vpc_sg_ids
  resource_owner         = var.resource_owner
}