/*
#AWS Redshift module
#Terraform module which attaches cluster_iam_roles
#Filename     : aws/modules/redshift/modules/cluster_iam_roles/main.tf 
#Date         : 15 Aug 2022
#Author       : TCS
#Description  : Terraform module for attaching of cluster_iam_roles
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

resource "aws_redshift_cluster_iam_roles" "cluster_roles" {
  cluster_identifier = var.cluster_identifier
  iam_role_arns      = var.iam_role_arns
}