##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/iam.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
module "codebuild_build_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.repo_name}-dispatch-role"
  description   = "IAM role for CodeBuild dispatch ${var.repo_name}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codebuild_dispatch.json")]
  policy_arns   = ["arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"]
}
