##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/output.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
output "codebuild_arn" {
  description = "Codebuild ARN"
  value       = aws_codebuild_project.dispatch.arn
}

output "codebuild_iam_role" {
  description = "Codebuild IAM Role"
  value       = module.codebuild_build_iam_role
}
