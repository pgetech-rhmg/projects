/*
 * # AWS module that creates a codepipeline that scans, builds, and deploys a container image for Locate & Mark
 * Terraform module which creates SAF2.0 Codepipeline in AWS
*/
##################################################################
#
#  Filename    : aws/modules/lm-pipeline/main.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
module "tags" {
  source  = "app.terraform.io/pgetech/lm-tags/aws"
  version = "~> 0.1.5"
}
