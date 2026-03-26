/*
 * # AWS module that creates a dispatcher to trigger codepipeline based on files changed
 * Terraform module which creates a SAF2.0 Codebuild Dispacther in AWS
*/
##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/main.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
module "tags" {
  source  = "app.terraform.io/pgetech/lm-tags/aws"
  version = "0.1.5"
}
