##################################################################
#
#  Filename    : aws/modules/lm-pipeline/locals.tf
#  Date        : 17 Oct 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
locals {
  environment = {
    "265171113329" = "Dev"
    "207567762899" = "QA"
    "944747578688" = "Prod"
  }[data.aws_caller_identity.current.account_id]

  branch = {
    Dev  = "dev"
    QA   = "qa"
    Prod = "main"
  }[local.environment]

  requires_approval_step  = contains(var.approval_branches, local.branch)
  full_file_path_includes = [for include in var.file_path_includes : "${var.build_path}/${include}"]
  full_file_path_excludes = [for exclude in var.file_path_excludes : "${var.build_path}/${exclude}"]
}
