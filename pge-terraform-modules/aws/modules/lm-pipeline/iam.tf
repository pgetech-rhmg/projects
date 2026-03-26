##################################################################
#
#  Filename    : aws/modules/lm-pipeline/iam.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
module "codepipeline_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.application_name}-pipeline-role"
  aws_service   = ["codepipeline.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codepipeline_iam_role.json")]
}

module "codebuild_build_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.1"
  name          = "${var.application_name}-build-role"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = module.tags.tags
  inline_policy = [file("${path.module}/iam_policies/codebuild_build_role.json")]
}
