/*
 * # AWS S3 module
 * Terraform module which creates SAF2.0 S3 static website resource in AWS
*/
#
# Filename    : modules/s3/s3_custom_bucket_policy/main.tf
# Date        : 17 June 2025
# Author      : pge
# Description : This module is used to create a custom S3 bucket policy that combines a user-defined policy with a predefined compliance policy.

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


locals {
  principal_orgid = "o-7vgpdbu22o"
  namespace       = "ccoe-tf-developers"

}


data "aws_iam_policy_document" "cloudfront_s3_readonly" {
  source_policy_documents = [
    templatefile("${path.module}/s3_bucket_policy.json",
      {
        bucket_name     = var.bucket_name
        principal_orgid = local.principal_orgid
    }, ),
    var.policy
  ]
}


resource "aws_s3_bucket_policy" "s3web" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.cloudfront_s3_readonly.json

}